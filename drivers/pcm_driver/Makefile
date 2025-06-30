ifeq ($(BOARD), Pynq-Z1)
C_SRC += pcm_driver.cpp
OBJSC += pcm_driver.o
endif

all:	
	$(CC) -fPIC -c -g3 -ggdb $(C_SRC) $(CFLAGS)
	$(CXX) -g3 -ggdb -shared -fPIC -rdynamic $(OBJSC) -Wl,--start-group $(LIBS) -Wl,--end-group -o libpcm.so $(CFLAGS) $(LDFLAGS)
	rm *.o