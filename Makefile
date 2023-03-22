.PHONY: build check-env

EXEC = hip_dgemm.x

default : $(EXEC)

build : default

$(EXEC) : check-env mod_ftime.o 
	$(HIPFORT)/bin/hipfc -lhipblas mod_ftime/mod_ftime.o hip_dgemm.f03 -o $@

hip_dgemm.o : mod_ftime.o

mod_ftime.o : check-env
	$(HIPFORT)/bin/hipfc -c mod_ftime/mod_ftime.f90

check-env:
ifndef HIPFORT
	$(error HIPFORT is not set)
endif

clean:
	$(RM) $(EXEC) mod_ftime/mod_ftime.o
