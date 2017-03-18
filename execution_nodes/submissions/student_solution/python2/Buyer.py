class Buyer:
	def __init__(self, cash=0):
		self.cash = cash

	def getCash(self):
		return self.cash

	def setCash(self,cash=0):
		self.cash = cash

	def buy(self, seller):
		if self.cash > 0:
			if seller.sell() == 1:
				self.cash -=1
