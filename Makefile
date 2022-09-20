build-image-local-arm64:
	docker buildx build \
	--load \
	--platform linux/arm64 \
	 --tag brain-hackers/gen1_builder:latest .

build-image-local-amd64:
	docker buildx build \
	--load \
	--platform linux/amd64 \
	 --tag brain-hackers/gen1_builder:latest .


build-image-push:
	docker buildx build \
	--push \
	--platform linux/arm64,linux/amd64 \
	 --tag brain-hackers/gen1_builder:latest .
