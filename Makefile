.PHONY: test

test:
	julia --project -e "using Pkg; Pkg.test()"