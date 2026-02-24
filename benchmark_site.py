#!/usr/bin/env python3
"""
Benchmark script to measure site performance before/after Redis deployment.
Usage: python benchmark_site.py
"""
import requests
import time
import statistics

URL = "https://cafe.ryan-lab.com"
HEALTH_URL = f"{URL}/health"
NUM_REQUESTS = 20

def benchmark():
    print(f"Benchmarking {URL}")
    print(f"Running {NUM_REQUESTS} requests...\n")
    
    times = []
    health_check = None
    
    for i in range(NUM_REQUESTS):
        start = time.time()
        try:
            response = requests.get(URL, timeout=10)
            elapsed = time.time() - start
            times.append(elapsed)
            print(f"Request {i+1}: {elapsed:.3f}s (Status: {response.status_code})")
        except requests.RequestException as e:
            print(f"Request {i+1}: FAILED - {e}")
    
    # Check Redis status
    try:
        health_response = requests.get(HEALTH_URL, timeout=5)
        health_check = health_response.json()
    except:
        health_check = {"error": "Could not fetch health status"}
    
    if times:
        print("\n" + "="*50)
        print("RESULTS:")
        print("="*50)
        print(f"Total Requests: {len(times)}")
        print(f"Average Time:   {statistics.mean(times):.3f}s")
        print(f"Median Time:    {statistics.median(times):.3f}s")
        print(f"Min Time:       {min(times):.3f}s")
        print(f"Max Time:       {max(times):.3f}s")
        print(f"Std Deviation:  {statistics.stdev(times):.3f}s" if len(times) > 1 else "N/A")
        print(f"\nRedis Status:   {health_check.get('redis', 'unknown')}")
        print("="*50)
    else:
        print("\nNo successful requests!")

if __name__ == "__main__":
    benchmark()
