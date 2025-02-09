require_relative './base_controller.rb'

module RailsPerformance
  class RailsPerformanceController < RailsPerformance::BaseController
    include RailsPerformance::ApplicationHelper

    protect_from_forgery except: :recent

    if RailsPerformance.enabled
      def index
        @datasource                = RailsPerformance::DataSource.new(**prepare_query, type: :requests)
        db                         = @datasource.db

        @throughput_report_data    = RailsPerformance::Reports::ThroughputReport.new(db).data
        @response_time_report_data = RailsPerformance::Reports::ResponseTimeReport.new(db).data
      end

      def summary
        @datasource                = RailsPerformance::DataSource.new(**prepare_query, type: :requests)
        db                         = @datasource.db

        @throughput_report_data    = RailsPerformance::Reports::ThroughputReport.new(db).data
        @response_time_report_data = RailsPerformance::Reports::ResponseTimeReport.new(db).data
        @data                      = RailsPerformance::Reports::BreakdownReport.new(db, title: "Requests").data

        respond_to do |format|
          format.js {}
          format.any { render plain: "Doesn't open in new window. Wait until full page load." }
        end
      end

      def trace
        @record = RailsPerformance::Models::RequestRecord.find_by(request_id: params[:id])
        @data   = RailsPerformance::Reports::TraceReport.new(request_id: params[:id]).data
        respond_to do |format|
          format.js {}
          format.any { render plain: "Doesn't open in new window. Wait until full page load." }
        end
      end

      def crashes
        @datasource   = RailsPerformance::DataSource.new(**prepare_query({status_eq: 500}), type: :requests)
        db            = @datasource.db
        @data         = RailsPerformance::Reports::CrashReport.new(db).data
      end

      def requests
        @datasource = RailsPerformance::DataSource.new(**prepare_query, type: :requests)
        db          = @datasource.db
        @data       = RailsPerformance::Reports::RequestsReport.new(db, group: :controller_action_format, sort: :count).data
      end

      def recent
        @datasource = RailsPerformance::DataSource.new(**prepare_query, type: :requests)
        db          = @datasource.db
        @data       = RailsPerformance::Reports::RecentRequestsReport.new(db).data(params[:from_timei])

        respond_to do |page|
          page.html
          page.js
        end
      end

      def sidekiq
        @datasource                = RailsPerformance::DataSource.new(**prepare_query, type: :sidekiq)
        db                         = @datasource.db
        @throughput_report_data    = RailsPerformance::Reports::ThroughputReport.new(db).data
        @response_time_report_data = RailsPerformance::Reports::ResponseTimeReport.new(db).data
        @recent_report_data        = RailsPerformance::Reports::RecentRequestsReport.new(db).data
      end

      def delayed_job
        @datasource                = RailsPerformance::DataSource.new(**prepare_query, type: :delayed_job)
        db                         = @datasource.db
        @throughput_report_data    = RailsPerformance::Reports::ThroughputReport.new(db).data
        @response_time_report_data = RailsPerformance::Reports::ResponseTimeReport.new(db).data
        @recent_report_data        = RailsPerformance::Reports::RecentRequestsReport.new(db).data
      end

      def custom
        @datasource                = RailsPerformance::DataSource.new(**prepare_query, type: :custom)
        db                         = @datasource.db
        @throughput_report_data    = RailsPerformance::Reports::ThroughputReport.new(db).data
        @response_time_report_data = RailsPerformance::Reports::ResponseTimeReport.new(db).data
        @recent_report_data        = RailsPerformance::Reports::RecentRequestsReport.new(db).data
      end

      def grape
        @datasource                = RailsPerformance::DataSource.new(**prepare_query, type: :grape)
        db                         = @datasource.db
        @throughput_report_data    = RailsPerformance::Reports::ThroughputReport.new(db).data
        @recent_report_data        = RailsPerformance::Reports::RecentRequestsReport.new(db).data
      end

      def rake
        @datasource                = RailsPerformance::DataSource.new(**prepare_query, type: :rake)
        db                         = @datasource.db
        @throughput_report_data    = RailsPerformance::Reports::ThroughputReport.new(db).data
        @recent_report_data        = RailsPerformance::Reports::RecentRequestsReport.new(db).data
      end

      private

      def prepare_query(query = params)
        RailsPerformance::Rails::QueryBuilder.compose_from(query)
      end
    end

  end
end