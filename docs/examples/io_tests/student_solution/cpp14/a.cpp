#include <cmath>
#include <cstdio>
#include <vector>
#include <iostream>
#include <algorithm>
using namespace std;

struct node{
    int data;
    node* left;
    node* right;
};

node* newNode(int data){
    node* n = new node();
    n->data = data;
    n->left = NULL;
    n->right = NULL;
    return n;
}

void insert(node* n, node* r){
    if(n->data <= r->data){
        if(r->left!=NULL)
        insert(n, r->left);
        if(r->left==NULL) r->left = n;
    }
    if(n->data > r->data){
        if(r->right!=NULL)
        insert(n, r->right);
        if(r->right==NULL) r->right = n;
    }
}

void inOrder(node *root) {
    if(root->left != NULL) inOrder(root->left);
    printf("%d ", root->data);
    if(root->right != NULL) inOrder(root->right);
}

void preOrder(node *root) {
    printf("%d ", root->data);
    if(root->left != NULL) preOrder(root->left);
    if(root->right != NULL) preOrder(root->right);
}

void postOrder(node *root) {
    if(root->left != NULL) postOrder(root->left);
    if(root->right != NULL) postOrder(root->right);
    printf("%d ", root->data);
}

int main() {
    int n, r;
    scanf("%d", &n);
    scanf("%d", &r);
    node* root = newNode(r); //Think for empty tree
    for(int i=0; i<n-1; i++){
        int data;
        scanf("%d", &data);
        node* node = newNode(data);
        insert(node, root);
    }
    
    inOrder(root);
    printf("\n");
    preOrder(root);
    printf("\n");
    postOrder(root);
    
    return 0;
}