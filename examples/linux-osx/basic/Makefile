# ocv_ar_basic Makefile
# make sure to provide the correct paths for
# HEADER_SEARCH_PATH and LIB_SEARCH_PATH below
# also check if OCV_AR_DIR points to your ocv_ar sources path

HEADER_SEARCH_PATH = /opt/local/include
LIB_SEARCH_PATH = /opt/local/lib 

CC = g++
CFLAGS = -g -Wall -I$(HEADER_SEARCH_PATH)
LDFLAGS = -g -L$(LIB_SEARCH_PATH) \
          -lopencv_core \
          -lopencv_imgproc \
          -lopencv_calib3d \
	  -lopencv_highgui

OCV_AR_DIR = ../../../ocv_ar

OCV_AR_SRC = $(OCV_AR_DIR)/detect.cpp \
	$(OCV_AR_DIR)/ident.cpp \
	$(OCV_AR_DIR)/ident_7x7.cpp \
	$(OCV_AR_DIR)/ident_templ.cpp \
	$(OCV_AR_DIR)/marker.cpp \
	$(OCV_AR_DIR)/tools.cpp
OCV_AR_OBJ = $(OCV_AR_SRC:.cpp=.o)
SRC = main.cpp
OBJ = main.o
PROG = ocv_ar_basic

all: $(OCV_AR_OBJ) $(OBJ)
	if [ -f detect.o ]; then for o in $(OCV_AR_OBJ); do mv `basename $$o` $(OCV_AR_DIR)/; done; fi
	$(CC) $(LDFLAGS) -o $(PROG) $(OCV_AR_OBJ) $(OBJ)

$(OCV_AR_OBJ): $(OCV_AR_SRC)
	$(CC) $(CFLAGS) -c $(OCV_AR_SRC)

$(OBJ): $(SRC)
	$(CC) $(CFLAGS) -c $(SRC)

clean:
	rm $(OCV_AR_OBJ)
	rm $(OBJ)
	rm $(PROG)
