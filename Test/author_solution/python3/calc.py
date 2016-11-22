class calc:
	def __init__(self):
		return

	def add(self,args):
		return sum(args)
	def sub(self,args):
		if len(args)<=1: return Exception("Enter atleast 2 parameters");
		a=args[0]
		for i in args[1:]:
			a-=i;
		return a;
	
