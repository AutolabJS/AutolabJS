class node:
    def __init__(self,key):
        self.left = None
        self.right = None
        self.val = key
        
def insert(root,node):
    if(root == None):
        root = node
        return root
        
    else:
        if(root.val < node.val):
            if(root.right == None):
                root.right = node
            else:
                insert(root.right, node)
            
        else:
            if(root.left == None):
                root.left = node
            else:
                insert(root.left, node)
        return root
          

 

def inorder(root):
    if(root != None):
        inorder(root.left)
        print (root.val, end=" ")
        inorder(root.right)
        
def preorder(root):
    if(root != None):
        
        print (root.val, end=" ")
        preorder(root.left)
        preorder(root.right)
        
def postorder(root):
    if(root != None):
        postorder(root.left)
        
        postorder(root.right)
        print (root.val, end=" ")
    
    

n = int(input())
l = list(map(int, input().split()))
#r = node(l[0])
r = None
for i in range(0,n):
    r = insert(r, node(l[i]))
    
    
inorder(r)
print("")
preorder(r)
print("")

postorder(r)
#print (r.val)