#!/usr/bin/env python3
import os
import sys
import subprocess
import urllib.request
from concurrent.futures import ThreadPoolExecutor
import time

def get_latest_artifact_id():
    cmd = [
        "gh", "api", "repos/BlazeNeuro/BNOS/actions/artifacts",
        "--jq", '.artifacts[] | select(.name=="bnos-live-iso") | .id'
    ]
    out = subprocess.check_output(cmd).decode().strip().splitlines()
    if out:
        return out[0].strip()
    raise RuntimeError("No bnos-live-iso artifact found")

def get_download_url(artifact_id):
    token = subprocess.check_output(["gh", "auth", "token"]).decode().strip()
    cmd = [
        "curl", "-s", "-IL",
        "-H", f"Authorization: Bearer {token}",
        f"https://api.github.com/repos/BlazeNeuro/BNOS/actions/artifacts/{artifact_id}/zip"
    ]
    out = subprocess.check_output(cmd).decode()
    for line in out.splitlines():
        if line.lower().startswith("location:"):
            return line.split(":", 1)[1].strip()
    raise RuntimeError("No redirect location found")

def download_chunk(artifact_id, url, start, end, filepath, chunk_id, progress_tracker):
    current_pos = start
    retries = 0
    max_retries = 30
    
    while current_pos <= end and retries < max_retries:
        try:
            req = urllib.request.Request(url)
            req.headers["Range"] = f"bytes={current_pos}-{end}"
            with urllib.request.urlopen(req, timeout=25) as resp:
                with open(filepath, "r+b") as f:
                    f.seek(current_pos)
                    while current_pos <= end:
                        buf = resp.read(65536)
                        if not buf:
                            break
                        f.write(buf)
                        bytes_read = len(buf)
                        current_pos += bytes_read
                        progress_tracker[chunk_id] += bytes_read
                        retries = 0 # reset on successful read
        except Exception as e:
            retries += 1
            time.sleep(1.5)
            if retries % 4 == 0:
                try:
                    url = get_download_url(artifact_id)
                except Exception:
                    pass

def main():
    if len(sys.argv) > 1:
        artifact_id = sys.argv[1]
    else:
        print("[*] Detecting latest artifact ID from GitHub Actions...")
        artifact_id = get_latest_artifact_id()
    
    print(f"[*] Target artifact ID: {artifact_id}")
    dest_dir = "/media/ankit/ARCH_ROOT/tmp/bnos-iso"
    os.makedirs(dest_dir, exist_ok=True)
    zip_path = os.path.join(dest_dir, f"bnos-live-iso-{artifact_id}.zip")

    print("[*] Resolving pre-signed download URL...")
    url = get_download_url(artifact_id)

    # Get total size
    req = urllib.request.Request(url, method="HEAD")
    with urllib.request.urlopen(req) as resp:
        total_size = int(resp.headers["Content-Length"])

    print(f"[*] Total artifact size: {total_size / (1024*1024):.1f} MB")

    num_threads = 8
    chunk_size = total_size // num_threads
    progress = [0] * num_threads

    # Pre-allocate file
    with open(zip_path, "wb") as f:
        f.seek(total_size - 1)
        f.write(b"\0")

    print(f"[*] Downloading with {num_threads} parallel threads to {zip_path}...")
    start_time = time.time()

    with ThreadPoolExecutor(max_workers=num_threads) as executor:
        futures = []
        for i in range(num_threads):
            start = i * chunk_size
            end = (start + chunk_size - 1) if i < num_threads - 1 else (total_size - 1)
            f = executor.submit(download_chunk, artifact_id, url, start, end, zip_path, i, progress)
            futures.append(f)

        while any(not f.done() for f in futures):
            downloaded = sum(progress)
            elapsed = time.time() - start_time
            speed = (downloaded / (1024 * 1024)) / max(0.1, elapsed)
            percent = (downloaded / total_size) * 100
            print(f"\r[*] {downloaded / (1024*1024):.1f} / {total_size/(1024*1024):.1f} MB ({percent:.1f}%) — {speed:.2f} MB/s", end="", flush=True)
            time.sleep(1)

        for f in futures:
            f.result()

    elapsed = time.time() - start_time
    print(f"\n[✓] Download finished in {elapsed:.1f}s (Average: {(total_size / (1024*1024)) / elapsed:.2f} MB/s)")

    print("[*] Unzipping artifact...")
    subprocess.check_call(["unzip", "-o", zip_path, "-d", dest_dir])
    print("[✓] Unzipped successfully!")
    
    # List generated ISO
    for f in os.listdir(dest_dir):
        if f.endswith(".iso") or f.endswith(".hybrid.iso"):
            iso_path = os.path.join(dest_dir, f)
            print(f"[✓] ISO ready at: {iso_path} ({os.path.getsize(iso_path)/(1024*1024):.1f} MB)")
            os.makedirs("/home/ankit/Desktop/BNOS/build", exist_ok=True)
            link_path = os.path.join("/home/ankit/Desktop/BNOS/build", f)
            if os.path.exists(link_path) or os.path.islink(link_path):
                os.remove(link_path)
            os.symlink(iso_path, link_path)
            print(f"[✓] Linked to {link_path}")
            break

if __name__ == "__main__":
    main()
