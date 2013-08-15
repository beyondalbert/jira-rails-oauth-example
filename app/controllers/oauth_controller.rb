#encoding: utf-8
class OauthController < ApplicationController

	@@call_back_url = "http://localhost:3000/oauth/callback"
	@@jira_host = "http://albert-yu:2990/jira"

	# jira-rsa.pem放置在rails的根目录中
	@@oauth_options = {
		:signature_method => 'RSA-SHA1',
		:request_token_path => @@jira_host + "/plugins/servlet/oauth/request-token",
		:authorize_path => @@jira_host + "/plugins/servlet/oauth/authorize",
		:access_token_path => @@jira_host + "/plugins/servlet/oauth/access-token",
		:private_key_file => "jira-rsa.pem",
		:rest_base_path => "/rest/api/2"
	}
	
	# consumer_key就是在jira的 Incoming Authentication 中自定义的一个字符串值
	@@consumer_key = "oauth-test"


  def index
  end

	def authorize
		@consumer = OAuth::Consumer.new(@@consumer_key, nil, @@oauth_options)
		# Ask for Request Token
		# Request Token issued after Service Provider successfully validates Consumer
		@request_token = @consumer.get_request_token(:oauth_callback => @@call_back_url)
		session[:request_token] = @request_token
		# User directed to Service Provider to approve Request Token(Log in may be required)
		redirect_to @request_token.authorize_url(:oauth_callback => @@call_back_url)
	rescue Errno::ECONNREFUSED
		flash[:notice] = "和jira通信被拒绝，请检查jira服务是否在线！"
		redirect_to :controller => "oauth", :action => "index"
	end

	# 用户被重定向到服务端进行认证，认证通过或不通过，服务端通过调用客户端的这个url返回具体的认证信息
	def callback
		session[:access_token] = nil
		session[:access_token_secret] = nil
		# Request Token exchanged for Access Token, which is issued to the Consumer
		@access_token = session[:request_token].get_access_token(:oauth_verifier => params[:oauth_verifier])

		# 保存access_token 和 access_token_secret，用于之后通过这两个参数进行access_token的重建
		# 一般情况下是保存在数据库
		session[:access_token] = @access_token.token
		session[:access_token_secret] = @access_token.secret

		redirect_to :controller => "oauth", :action => "index"
	rescue OAuth::Unauthorized
		flash[:notice] = "你拒绝了jira的认证，请重新认证！"
		redirect_to :controller => "oauth", :action => "index"
	end

	def auth_test
		# 通过 access_token、access_token_secret和consumer重新构建access_token
		# 这样就可以在access_token的有效期内，不用重复走认证流程
		@consumer = OAuth::Consumer.new(@@consumer_key, nil, @@oauth_options)
		@access_token = OAuth::AccessToken.new(@consumer, session[:access_token], session[:access_token_secret])

		# TESTFT-1为jira中一个issue的id值，更多jira api接口请查看jira接口文档
		issue_info = @access_token.get(@@jira_host + "/rest/api/latest/issue/TESTFT-1")
		p "----------------->issue info:"
		p JSON.parse(issue_info.body)
		flash[:notice] = "jira认证测试成功，jira中的issue信息请看log！"
		redirect_to :controller => "oauth", :action => "index"
	end
end
