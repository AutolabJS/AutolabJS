from Buyer import Buyer

class Test:
	def test(self):
		buyer = Buyer(100)

		if buyer.getCash()==100:
			buyer.setCash(20)
			if buyer.getCash()==20:
				return 1
		else:
			return 0

