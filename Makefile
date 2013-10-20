default: test

cpp:
	haxe compile_cpp.hxml

js:
	haxe compile_js.hxml # generates coopy.js
	cat coopy.js scripts/post_node.js > coopy_node.js
	sed 's/window != "undefined" ? window : exports/exports != "undefined" ? exports : window/' coopy_node.js > coopy.js  # better order for browserify
	cat coopy.js scripts/coopy_view.js > coopyhx.js
	@wc coopyhx.js

min: js
	uglifyjs coopyhx.js > coopyhx.min.js
	gzip -k -f coopyhx.min.js
	@wc coopyhx.js
	@wc coopyhx.min.js
	@wc coopyhx.min.js.gz

test: js
	./scripts/run_tests.sh
	@echo "=============================================================================="

csv2html: js
	./scripts/assemble_csv2html.sh

doc:
	haxe -xml doc.xml compile_js.hxml
	haxedoc doc.xml -f coopy
	# 
	# result is in index.html and content directory


cpp_package:
	haxe compile_cpp_for_package.hxml

php:
	haxe compile_php.hxml
	cp scripts/PhpTableView.class.php php_bin/lib/coopy/
	cp scripts/example.php php_bin/
	@echo 'Output in php_bin, run "php php_bin/index.php" for an example utility'
	@echo 'or try "php php_bin/example.php" for an example of using coopyhx as a library'


java:
	haxe compile_java.hxml
	@echo 'Output in java_bin, run "java -jar java_bin/java_bin.jar" for help'

cs:
	haxe compile_cs.hxml
	@echo 'Output in cs_bin, do something like "gmcs -recurse:*.cs -main:coopy.Coopy -out:coopyhx.exe" in that directory'


release: js test php
	rm -rf release
	mkdir -p release
	cp coopyhx.js release
	mv php_bin coopyhx_php
	rm -f coopyhx_php.zip
	zip -r coopyhx_php coopyhx_php
	mv coopyhx_php.zip release
	rm -f /tmp/coopyhx_cpp/build/coopyhx_cpp.zip
	cd packaging/cpp_recipe && ./build_cpp_package.sh
	cp /tmp/coopyhx_cpp/build/coopyhx_cpp.zip release
