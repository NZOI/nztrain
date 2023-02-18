require 'spec_helper'

describe ApplicationController do

  describe "XML authorization" do
    controller(UserController) do
    end
    before(:each) do
      @user = users(:user)
    end

    it "allows admin to view XML" do
      sign_in users(:admin)
      get :show, :id => @user.to_param, :format => :xml
      expect(response).to be_success
      expect(response.body).to include("<email>#{@user.email}</email>")
    end

    it "forbids a normal user from viewing XML" do
      sign_in users(:user)
      get :show, :id => @user.to_param, :format => :xml
      expect(response).to have_http_status(:forbidden)
      expect(response.body).not_to include(@user.email)
    end

    it "forbids an unauthenticated user from viewing XML" do
      # no sign in
      get :show, :id => @user.to_param, :format => :xml
      expect(response).to have_http_status(:forbidden)
      expect(response.body).not_to include(@user.email)
    end

    context "when using the HTTP 'Accept' header" do
      it "forbids viewing XML" do
        sign_in users(:user)
        request.headers["Accept"] = "application/xml"
        get :show, :id => @user.to_param
        expect(response).to have_http_status(:forbidden)
        expect(response.body).not_to include(@user.email)
      end
      it "forbids viewing XML when the 'Accept' header has multiple media types" do
        sign_in users(:user)
        request.headers["Accept"] = "text/plain;q=0.8, text/xml;q=0.2"
        get :show, :id => @user.to_param
        expect(response).to have_http_status(:forbidden)
        expect(response.body).not_to include(@user.email)
      end
    end

    context "when the controller calls `render xml:` without calling `respond_to`" do
      # Our controllers use the pattern <code>respond_to do |format| format.xml { render :xml => ... } end</code>.
      # It is also possible to call <code>render :xml => ...</code> directly, which behaves slightly differently
      # (e.g. it calls <code>content_type=</code> with a Mime::Type rather than with a string).
      # This test case checks that XML is forbidden even if the controller calls <code>render</code> directly.
      controller(UserController) do
        def show
          @user = User.find(params[:id])
          render :xml => @user
        end
      end
      it "forbids viewing XML" do
        sign_in users(:user)
        get :show, :id => @user.to_param, :format => :xml
        expect(response).to have_http_status(:forbidden)
        expect(response.body).not_to include(@user.email)
      end
    end

    context "when `content_type=` is bypassed" do
      # The <code>content_type=</code> check in application_controller.rb is slightly fragile,
      # so there is also an <code>after_filter</code> that verifies no XML slipped through.
      # This test cases checks that the <code>after_filter</code> works.
      controller(UserController) do
        def show
          @user = User.find(params[:id])
          response.content_type = "application/xml"
          self.response_body = @user.to_xml
        end
      end
      it "raises an error" do
        sign_in users(:user)
        expect { get :show, :id => @user.to_param, format: :xml }.to raise_error(/XML.*forbidden/)
      end
    end
  end

end
