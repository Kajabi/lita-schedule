require "lita/schedule/version"

module Lita
  class Schedule
    extend Forwardable

    attr_reader :redis
    attr_reader :robot

    Job = Struct.new('Job', :type, :field, :job_name)

    class << self
      def cron(field, job_name)
        jobs << Job.new(:cron, field, job_name)
      end

      def every(field, job_name)
        jobs << Job.new(:cycle, field, job_name)
      end

      def jobs
        @jobs ||= []
      end

      def namespace
        if name
          Util.underscore(name.split("::").last)
        else
          raise "Schedules that are anonymous classes must define self.name."
        end
      end
    end

    def initialize(robot)
      @robot = robot
      @redis = Redis::Namespace.new(redis_namespace, redis: Lita.redis)
    end

    private

    def redis_namespace
      "schedules:#{self.class.namespace}"
    end
  end
end
