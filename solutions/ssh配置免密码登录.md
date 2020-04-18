1.个人电脑生成公私密钥

```she
cd ~/.ssh/
ssh-keygen -t rsa -C "youremail@example.com"  填写自己的邮箱
```

2.连接远程服务器，将公钥写入authorized_keys（目录下没有就新建一个）

```shel
cd ~/.ssh/
vim authorized_keys
```

