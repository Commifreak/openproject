#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2022 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

require_relative '../spec_helper'

# These specs mainly check that error messages from a sub-service
# (about unsafe hosts with HTTP protocol) are passed to the main form.
describe ::Storages::Admin::StoragesController, with_flag: { storages_module_active: true }, type: :controller do
  render_views # rendering views is stubbed by default in controller specs
  include StorageServerHelpers

  let(:admin) { create :admin }
  let(:host) { "www.example.com" }
  let(:content_type_json) { { 'Content-Type' => 'application/json; charset=utf-8' } }

  before do
    login_as admin
  end

  describe 'with valid attributes', webmock: true do
    let(:params) { { storages_storage: { name: "My Nextcloud", host: "https://#{host}" } } }

    before do
      mock_server_capabilities_response("https://#{host}")
      post :create, params:
    end

    it 'is successful' do
      expect(response).to be_successful
      expect(response.body).not_to include("Redirect uri must be an HTTPS/SSL URI")
      expect(response.body).to include(I18n.t(:notice_successful_create))
    end
  end

  describe 'with invalid attributes', webmock: true do
    let(:params) { { storages_storage: { name: "My Nextcloud", host: "http://#{host}" } } }

    before do
      mock_server_capabilities_response("http://#{host}")
      post :create, params:
    end

    it 'complains about HTTP being invalid' do
      expect(response).to be_successful # you get a 200 response despite errors...
      expect(response.body).to include("Redirect uri must be an HTTPS/SSL URI")
    end
  end
end
