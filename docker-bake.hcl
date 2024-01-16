# docker-bake.hcl
variable "VERSION" {
}

variable "PLATFORMS" {
  default = ["linux/amd64", "linux/arm64"]
}

variable "TARGETS" {
  default = ["aiida-core", "aiida-with-gromacs"]
}

function "tags" {
  params = [image]
  result = [
    "harbor.stfc.ac.uk/biosimulation-cloud/${image}:v0.0.13"
  ]
}

group "default" {
  targets = "${TARGETS}"
}

target "aiida-core-meta" {
  tags = tags("aiida-core")
}
target "aiida-with-gromacs-meta" {
  tags = tags("aiida-with-gromacs")
}

target "aiida-core" {
  inherits = ["aiida-core-meta"]
  context = "aiida-core"
  platforms = "${PLATFORMS}"
  args = {
    "AIIDA_VERSION" = "${AIIDA_VERSION}"
    "PYTHON_VERSION" = "${PYTHON_VERSION}"
  }
}
target "aiida-with-gromacs" {
  inherits = ["aiida-with-gromacs-meta"]
  context = "aiida-with-gromacs"
  contexts = {
    aiida-core = "target:aiida-core"
  }
  platforms = "${PLATFORMS}"
  args = {
    "GMX_VERSION" = "${GMX_VERSION}"
    "PGSQL_VERSION" = "${PGSQL_VERSION}"
    "RMQ_VERSION" = "${RMQ_VERSION}"
  }
}
