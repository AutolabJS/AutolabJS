#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
struct node{
    int key;
    struct node* right;
    struct node* left;
};
struct node *newNode(int item){
    struct node *temp =  (struct node *)malloc(sizeof(struct node));
    temp->key = item;
    temp->left = temp->right = NULL;
    return temp;
}
struct node* insert(struct node* root,int key){
    if(root==NULL)
    return newNode(key);
    if(root->key>=key)
    root->left  = insert(root->left,key);
    if(root->key<key)
    root->right = insert(root->right,key);
    return root;
}
void inorder(struct node *root){
    if(root!= NULL){
        inorder(root->left);
        printf("%d ",root->key);
        inorder(root->right);
    }
}
void preorder(struct node *root){
    if(root!= NULL){
        printf("%d ",root->key);
        preorder(root->left);
        preorder(root->right);
    }
}
void postorder(struct node *root){
    if(root!= NULL){
        postorder(root->left);
        postorder(root->right);
        printf("%d ",root->key);
    }
    
}
int main() {
    
    /* Enter your code here. Read input from STDIN. Print output to STDOUT */
    int i,item;
    struct node *root = NULL;
    long int n;
    scanf("%ld",&n);
    scanf("%d",&item);
    root = insert(root,item);
    for(i=1;i<n;i++){
        scanf("%d",&item);
        //if(i==0)
        
        insert(root,item);
    }
    inorder(root);
    printf("\n");
    preorder(root);
    printf("\n");
    postorder(root);
    return 0;
}

