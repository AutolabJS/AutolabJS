class Seller:
	quantity = 0

	def __init__(self, quantity=0):
		self.quantity = quantity

	def getQuantity(self):
		return self.quantity

	def setQuantity(self,quantity=0):
		self.quantity = quantity

	def sell(self):
		if self.quantity > 0:
			self.quantity -= 1
			return 1
		else:
			return 0		
