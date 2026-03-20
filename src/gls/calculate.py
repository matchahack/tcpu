import re

INPUT_FILE = "gls/gatecount.txt"

# Pattern to detect module headers
module_pattern = re.compile(r"^===\s+(\S+)\s+===")
# Pattern to detect cell lines
cell_line_pattern = re.compile(r"^\s*(\S+)\s+(\d+)$")

module_counts = {}
current_module = None

with open(INPUT_FILE, "r") as f:
    for line in f:
        line = line.strip()
        # Detect new module
        m = module_pattern.match(line)
        if m:
            current_module = m.group(1)
            module_counts[current_module] = {}
            continue
        # Detect cell lines
        if current_module:
            c = cell_line_pattern.match(line)
            if c:
                cell_name = c.group(1)
                count = int(c.group(2))
                module_counts[current_module][cell_name] = count

# Print total cells per module
print(f"{'Module':<20} Total Cells")
print("="*35)
for module, cells in module_counts.items():
    total_cells = sum(cells.values())
    print(f"{module:<20} {total_cells}")

# Total for all modules
total_all = sum(sum(cells.values()) for cells in module_counts.values())
print("\nTotal cells in design:", total_all)