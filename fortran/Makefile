FC = gfortran
FFLAGS = -O2 -Wall
LIBS = -lcurl -lssl -lcrypto

CORE = core/utils.f90 core/json_minimal.f90 core/net_http.f90
SQLC = sqlitecloud/sqlitecloud_wrapper.f90
EX   = examples/demo_sqlitecloud.f90

OBJ = $(CORE:.f90=.o) $(SQLC:.f90=.o)

all: demo_sqlitecloud

demo_sqlitecloud: $(OBJ) $(EX)
	$(FC) $(FFLAGS) -o ../build/demo_sqlitecloud $(OBJ) $(EX) $(LIBS)

clean:
	rm -f core/*.o sqlitecloud/*.o examples/*.o ../build/*
