import sys

if len(sys.argv) != 4:
  print "usage: threshold.py inputfile.pgm outputfile.pgm threshold"
  sys.exit(1)

def threshold(num):
  if num < int(sys.argv[3]):
    return "0"
  return str(num)

with open(sys.argv[1], "r") as inputfile:
  with open(sys.argv[2], "w") as outputfile:
    for line in inputfile:
      if len(line.split(" ")) == 40:
        outputfile.write(" ".join(map(lambda x : threshold(int(x)), line.split(" "))) + "\n")
      else:
        outputfile.write(line + "\n")
