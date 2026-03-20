import re
from collections import defaultdict, deque

FIELDS = [
    "Number of wires",
    "Number of wire bits",
    "Number of public wires",
    "Number of public wire bits",
    "Number of memories",
    "Number of memory bits",
    "Number of processes",
    "Number of cells",
]

def parse_report(filename):
    modules = {}
    instances = defaultdict(list)

    current_module = None

    with open(filename, "r") as f:
        for line in f:
            line = line.strip()

            # Module header
            if line.startswith("===") and line.endswith("==="):
                current_module = line.strip("= ").strip()
                modules[current_module] = defaultdict(int)
                continue

            # Field extraction
            for field in FIELDS:
                if line.startswith(field):
                    value = int(re.findall(r"\d+", line)[0])
                    modules[current_module][field] = value

            # Instance detection (lines like: module_name   count)
            if line.startswith("$") or line.startswith("cpu_") or line.startswith("data_") or line.startswith("uart_") or line.startswith("chip_") or line.startswith("io_"):
                parts = line.split()
                if len(parts) == 2 and parts[1].isdigit():
                    inst_name = parts[0]
                    instances[current_module].append(inst_name)

    return modules, instances


def find_reachable(modules, instances, top):
    reachable = set()
    queue = deque([top])

    while queue:
        mod = queue.popleft()
        if mod in reachable:
            continue
        reachable.add(mod)

        for child in instances.get(mod, []):
            if child in modules:
                queue.append(child)

    return reachable


def summarize(modules, reachable):
    totals = defaultdict(int)

    print("\n=== INCLUDED MODULES (reachable) ===")
    for mod in sorted(reachable):
        print(mod)
        for field in FIELDS:
            totals[field] += modules[mod].get(field, 0)

    print("\n=== TOTALS (reachable only) ===")
    for field in FIELDS:
        print(f"{field}: {totals[field]}")


if __name__ == "__main__":
    filename = "gls/gatecount.txt"
    top_module = "control"  # <-- change if needed

    modules, instances = parse_report(filename)
    reachable = find_reachable(modules, instances, top_module)
    summarize(modules, reachable)