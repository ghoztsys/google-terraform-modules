variable basename {
  description = "The basename of the generated UUID."
}

variable environment {
  default = "development"
  description = "The environment used to generate the UUID. This environment string automatically gets shortened to 3 characters."
}
