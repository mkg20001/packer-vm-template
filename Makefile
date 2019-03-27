build: prepare
	packer build packer.json

prepare:
	rm -rf provision
	mkdir provision
	tar cvfzp provision/git.tar.gz .git
	cd ..
	rm -rf node_modules package-lock.json
	npm i
	OVERRIDE_LOCATION=/var/lib/$VM_NAME npx dpl-tool ./deploy.yaml > provision/deploy.sh
	PROV=$(PWD)/provision make -C $(PWD)/.. prepare
	cd $(PWD)
	tar cvfz provision.tar.gz provision/
	mv provision.tar.gz provision/bundle.tar.gz
export:
	bash scripts/post-process.sh
	tar cvf $VM_NAME.tar.xz --lzma $VM_NAME

dist: build export
