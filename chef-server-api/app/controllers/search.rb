#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Brown (<cb@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require 'chef/solr/query'

class ChefServerApi::Search < ChefServerApi::Application
  provides :json
 
  # TODO: this before filter is commented out at this time for testing the webui work. This should be added back in the future [nuo]
  #before :authenticate_every
  
  def index
    indexes = valid_indexes
    display(indexes.inject({}) { |r,i| r[i] = absolute_slice_url(:search, i); r })    
  end

  def valid_indexes
    indexes = Chef::DataBag.cdb_list(false)
    indexes << "role"
    indexes << "node"
  end

  def show
    unless valid_indexes.include?(params[:id])
      raise NotFound, "I don't know how to search for #{params[:id]} data objects."
    end

    query = Chef::Solr::Query.new(Chef::Config[:solr_url], Chef::Config[:couchdb_database])
    params[:q]     ||= "*:*"
    params[:sort]  ||= nil
    params[:start] ||= 0
    params[:rows]  ||= 20
    objects, start, total = query.search(params[:id], params[:q], params[:sort], params[:start], params[:rows])
    display({
      "rows" => objects,
      "start" => start,
      "total" => total
    })
  end

end
