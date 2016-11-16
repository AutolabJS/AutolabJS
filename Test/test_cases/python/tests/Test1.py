from calc import calc

class Test:
	
	def __init__(self):
		self.Mycalc=calc();

	def run(self):
		if self.Mycalc.add([2,3,5])==10: return 10;
		return 0;