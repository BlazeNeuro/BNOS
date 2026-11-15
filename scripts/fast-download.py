import os
import sys
import subprocess
import urllib.request
from concurrent.futures import ThreadPoolExecutor
import time

def get_download_url():
    token = subprocess.check_output(["gh", "auth", "token"]).decode().strip()
    cmd = [
        "curl", "-s", "-IL",
        "-H", f"Authorization: Bearer {token}",
        "https://api.github.com/repos/BlazeNeuro/BNOS/actions/artifacts/14168120255/zip"
    ]
    out = subprocess.check_output(cmd).decode()
    for line in out.splitlines():
        if line.lower().startswith("location:"):
            return line.split(":", 1)[1].strip()
    raise RuntimeError("No redirect location found")

def download_chunk(url, start, end, filepath, chunk_id, progress_tracker):
    req = urllib.request.Request(url)
    req.headers["Range"] = f"bytes={start}-{end}"
    
    with urllib.request.urlopen(req, timeout=60) as resp:
        with open(filepath, "r+b") as f:
            f.seek(start)
            while True:
                buf = resp.read(65536)
                if not buf:
                    break
                f.write(buf)
                progress_tracker[chunk_id] += len(buf)

def main():
    dest_dir = "/media/ankit/ARCH_ROOT/tmp/bnos-iso"
    os.makedirs(dest_dir, exist_ok=True)
    zip_path = os.path.join(dest_dir, "bnos-live-iso.zip")

    print("[*] Resolving direct Azure Blob URL...")
    url = get_download_url()
    
    req = urllib.request.Request(url, method="HEAD")
    with urllib.request.urlopen(req, timeout=30) as resp:
        total_size = int(resp.headers.get("Content-Length"))

    print(f"[*] Total size: {total_size / (1024*1024):.2f} MB")
    
    # Pre-allocate file
    with open(zip_path, "wb") as f:
        f.truncate(total_size)

    num_threads = 16
    chunk_size = total_size // num_threads
    futures = []
    progress = [0] * num_threads

    start_time = time.time()
    print(f"[*] Starting 16-thread parallel stream download...")

    with ThreadPoolExecutor(max_workers=num_threads) as executor:
        for i in range(num_threads):
            start = i * chunk_size
            end = (start + chunk_size - 1) if i < num_threads - 1 else (total_size - 1)
            f = executor.submit(download_chunk, url, start, end, zip_path, i, progress)
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
