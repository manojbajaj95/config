import sys
historyCache={}

def loadFile(filename):
    with open(filename,'r') as f:
        buffer = f.read()
        commands = buffer.split("\n:")[1:] # \n: is used as separator for each history command
        for command in commands:
            try:
                cmd = command.split(";")[1]
                historyCache[cmd]=command
            except :
                #  This is probably multiline command which is yet to be handled
                print(command)
            # break

def writeFile(filename):
    with open(filename,'w') as f:
        for k,v in historyCache.items():
            f.write(": " + v + "\n")

if __name__ == "__main__":
    histFile = sys.argv[1]
    loadFile(histFile);
    writeFile(histFile);
