
run: patch.apply node_modules/
	bun run expo start

node_modules/: package.json
	bun install

patch.apply:
	-git -C 3rdparty/react-native-skia apply ../../$$(ls patch*) > /dev/null 2>&1

init: # init submodules
	git submodule update --init --progress --depth=1
	git -C 3rdparty/react-native-skia sparse-checkout init
	git -C 3rdparty/react-native-skia sparse-checkout add example

update_git_index:
	git -C 3rdparty/react-native-skia fetch --tags --no-recurse-submodules

update_rn_skia:
	bun expo install @shopify/react-native-skia
update: update_rn_skia update_git_index
	$(eval VERSION := $(shell jq -r '.dependencies."@shopify/react-native-skia"' package.json))
	$(eval TAG := $(shell git -C 3rdparty/react-native-skia tag | rg '$(VERSION)'))
	echo "checkout tag: $(TAG)"
	git -C 3rdparty/react-native-skia checkout $(TAG)
	mv $${ls patch*} patch_$(VERSION).patch
	make patch.apply
