# jira-rails-oauth-example
rails如何通过OAuth，从jira平台抓取数据
环境：rails 3.2 ruby 1.9.3

## 准备工作：

### 在本地设置和启jira开发环境

参考：https://developer.atlassian.com/display/DOCS/Set+up+the+Atlassian+Plugin+SDK+and+Build+a+Project

### 了解jira的OAuth流程

参考：https://confluence.atlassian.com/display/GADGETS/Configuring+OAuth

### 如何配置jira的OAuth功能：

参考：http://www.prodpad.com/2013/05/tech-tutorial-oauth-in-jira/

### 生成RSA密钥对（linux下示例）

    openssl genrsa -out jira-rsa.pem 1024
    openssl rsa -in jira-rsa.pem -pubout -out jira-rsa.pub

In this example, jira.pem is the private key file; and jira.pub is the public key.

## rails通过OAuth连接jira：

具体的认证过程可参看代码

## 示例试用：

* 1、本地启一个jira的开发环境，作为服务端（如果有真实的jira平台，该过程就可免）；

* 2、配置好jira的 Oauth 服务；

* 3、clone本代码，设置好rails环境，启动rails服务





