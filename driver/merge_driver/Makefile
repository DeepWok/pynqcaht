ifeq ($(BOARD), Pynq-Z1)
C_SRC += merge_driver.cpp
OBJSC += merge_driver.o
endif

all:	
	$(CC) -fPIC -c -g3 -ggdb $(C_SRC) $(CFLAGS)
	$(CXX) -g3 -ggdb -shared -fPIC -rdynamic $(OBJSC) -Wl,--start-group $(LIBS) -Wl,--end-group -o libmerge.so $(CFLAGS) $(LDFLAGS)
	rm *.o