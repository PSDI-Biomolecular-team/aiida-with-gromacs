# aiida-with-gromacs

A container aimed at making the PSDI toolchain simpler to use by incorporating
AiiDA, PostGRES, RabbitMQ, GROMACS and aiida-gromacs all into a single
container.

### Run instructions

TODO: This needs better examples.

docker run -it harbor.stfc.ac.uk/biosimulation-cloud/aiida-with-gromacs:v0.0.13 bash

### Multiarch builds

#### Set up binfmt to bring the multiarch support.
docker run --privileged --rm tonistiigi/binfmt --install all
sudo apt-get install -y qemu qemu-user-static

#### Create a multiarch builder for buildx.
docker buildx create --name psdi-builder --bootstrap --use

#### Check that the architectures show in the builder.
docker buildx ls

#### Build container
docker buildx bake -f build.json -f docker-bake.hcl --load
