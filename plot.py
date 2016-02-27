import json

import matplotlib.pyplot as plt

with open("trades.json", "r") as f:
    data = json.load(f)
    for symbol in data:
        print symbol
        plt.plot(map(lambda d: d["price"], data[symbol]), label=symbol)
plt.ylabel('Prices')
plt.show()
