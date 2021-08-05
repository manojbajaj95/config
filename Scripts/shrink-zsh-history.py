import sys
historyCache={}

def loadFile(filename):
    with open(filename,'r') as f:
        for line in f:
            try:
                cmd = line.split(";")[1]
                historyCache[cmd]=line
            except :
                #  This is probably multiline command which is yet to be handled
                print(line)

def writeFile(filename):
    with open(filename,'w') as f:
        for k,v in historyCache.items():
            f.write(v)

if __name__ == "__main__":
    histFile = sys.argv[1]
    loadFile(histFile);
    writeFile(histFile);
