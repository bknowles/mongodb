#
# Cookbook Name:: mongodb
# Recipe:: 10gen_repo
#
# Copyright 2011, edelight GmbH
# Authors:
#       Miquel Torres <miquel.torres@edelight.de>
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
#

# Sets up the repositories for stable 10gen packages found here:
# http://www.mongodb.org/downloads#packages

case node['platform']
when "debian", "ubuntu"
  # Adds the repo: http://www.mongodb.org/display/DOCS/Ubuntu+and+Debian+packages
  Chef::Log.debug("Adding the #{node['platform']} 10gen repository w/ apt")
  execute "apt-get update" do
    action :nothing
  end

  apt_repository "10gen" do
    uri "http://downloads-distro.mongodb.org/repo/debian-sysvinit"
    distribution "dist"
    components ["10gen"]
    keyserver "keyserver.ubuntu.com"
    key "7F0CEB10"
    action :add
    notifies :run, "execute[apt-get update]", :immediately
  end

  package "mongodb" do
    package_name "mongodb-10gen"
  end
when "centos","redhat","scientific"
  # Adds the repo: http://www.mongodb.org/display/DOCS/CentOS+and+Fedora+Packages
  Chef::Log.debug("Adding the #{node['platform']} 10gen repository w/ yum")
  include_recipe "yum"

  yum_repository "10gen" do
    Chef::Log.debug("Defining 10gen repository for yum")
    description "10gen MongoDB repo"
    url "http://downloads-distro.mongodb.org/repo/redhat/os/#{node[:kernel][:machine]}"
    failovermethod "priority"
    action :add
  end

  package "mongodb" do
    Chef::Log.debug("Linking our package name to the 10gen repo name")
    package_name "mongo-10gen-server"
  end

  yum_package "mongo-10gen-server" do
    Chef::Log.debug("Installing package mongodb w/ yum")
    action :install
  end

  Chef::Log.debug("Added the #{node['platform']} 10gen repository w/ yum")
  #end redhat/centos/scientific block
else
    Chef::Log.warn("Adding the #{node['platform']} 10gen repository is not yet not supported by this cookbook")
end
