module AfterTransactionCommit
  module Transaction
    if ::ActiveRecord.version >= Gem::Version.new("6.1")
      def initialize(connection, **options)
        super
        @after_commit_blocks = []
      end
    else
      def initialize(connection, options, run_commit_callbacks: false)
        super
        @after_commit_blocks = []
      end
    end

    def add_after_commit(block)
      @after_commit_blocks << block
    end

    def commit_records
      super
      if @run_commit_callbacks
        @after_commit_blocks.each(&:call)
      else
        connection.current_transaction.instance_variable_get(:@after_commit_blocks).concat(@after_commit_blocks)
      end
    end
  end
end
