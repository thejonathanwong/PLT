#stuff for compiling cpp files
CXX = g++
CPPDIR = ./cpp
INC = $(CPPDIR) ./includes/headers
INCLUDES =$(INC:%=-I%)
CXXFLAGS = -g -Wall $(INCLUDES)

OBJS = ast.cmo sast.cmo parser.cmo scanner.cmo analyzer.cmo generator.cmo qlc.cmo

.PHONY: default

default: qlc cpp/qlang.o


qlc : $(OBJS) 
	ocamlc -g -o qlc $(OBJS)

scanner.ml : scanner.mll
	ocamllex scanner.mll

parser.ml parser.mli : parser.mly
	ocamlyacc parser.mly

%.cmo : %.ml
	ocamlc -g -c $<

%.cmi : %.mli
	ocamlc -g -c $<

cpp/qlang.o:
	$(MAKE) -C $(CPPDIR)


.PHONY : clean
clean :
	rm -f qlc parser.ml parser.mli scanner.ml *.cmo *.cmi
	$(MAKE) -C $(CPPDIR) clean

# Generated by ocamldep *.ml *.mli
analyzer.cmo: sast.cmo ast.cmo
analyzer.cmx: sast.cmx ast.cmx
generator.cmo: sast.cmo
generator.cmx: sast.cmx
parser.cmo: ast.cmo parser.cmi 
parser.cmx: ast.cm parser.cmi 
qlc.cmo: scanner.cmo sast.cmo parser.cmi ast.cmo analyzer.cmo
qlc.cmx: scanner.cmx sast.cmo parser.cmx ast.cmx analyzer.cmx
sast.cmo: ast.cmo
sast.cmx: ast.cmx
scanner.cmo: parser.cmi 
scanner.cmx: parser.cmx 
parser.cmi: ast.cmo
