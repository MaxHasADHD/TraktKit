import re
import sys

def update_test_code(file_path):
	with open(file_path, "r", encoding="utf-8") as f:
		content = f.read()

	# Matches each test function with its body
	test_function_pattern = re.compile(r'(func test_[a-zA-Z0-9_]+\(\))\s*\{((?:.|\n)*?)\n\s{4}\}', re.DOTALL)

	def process_test_function(match):
		func_def, body = match.groups()
		print(f"body debug: {body}")

		# Skip if already updated (contains `mock(...)`)
		if "mock(" in body:
			return match.group(0)

		# Ensure `throws` is correctly added after the parentheses
		if "throws" not in func_def:
			func_def = func_def.rstrip('()') + "() throws {"

		# Extract JSON filename in this function
		next_data_match = re.search(r'session\.nextData = jsonData\(named: "(.*?)"\)', body)
		json_filename = next_data_match.group(1) if next_data_match else None

		# Extract URL in this function
		url_match = re.search(r'XCTAssertEqual\(session\.lastURL\?\.(?:absoluteString)?, "(.*?)"\)', body)
		url = url_match.group(1) if url_match else None
		
		print(f"json filename debug: {json_filename}")
		print(f"url debug: {url}")

		# Apply transformations only if both values exist
		if json_filename and url:
			# Replace `session.nextData` line with `mock(...)`
			body = re.sub(
				r'session\.nextData = jsonData\(named: ".*?"\)',
				f'try mock(.GET, "{url}", result: .success(jsonData(named: "{json_filename}")))',
				body
			)

			# Remove `XCTAssertEqual(session.lastURL...)`
			body = re.sub(r'XCTAssertEqual\(session\.lastURL\?\.(?:absoluteString)?, ".*?"\)\n?', '', body)

		# Add the closing bracket `}` at the end
		return f"{func_def}{body}\n    }}"

	# Apply transformation to all functions in the file
	updated_content = test_function_pattern.sub(process_test_function, content)

	with open(file_path, "w", encoding="utf-8") as f:
		f.write(updated_content)

	print(f"Updated {file_path}")

if __name__ == "__main__":
	if len(sys.argv) < 2:
		print("Usage: python update_tests.py <file1> <file2> ...")
		sys.exit(1)

	for file_path in sys.argv[1:]:
		update_test_code(file_path)
