# frozen_string_literal: true

class MockLogger
  def log(message)
    "Logged: #{message}"
  end
end

class MockTaskManager
  def create_task(name)
    "Task #{name} created"
  end
end

class ValidUseCase
  include DepInject

  provide(
    logger: MockLogger,
    task_manager: MockTaskManager
  )

  def execute(task_name)
    task = prepare_task(task_name)
    @logger.log("Executing #{task}")
  end

  private

  def prepare_task(task_name)
    @task_manager.create_task(task_name)
  end
end

class MockAddTaskCommand
  include DepInject
  provide()
  def execute(name)
    "Task #{name} created"
  end
end

class OtherValidUseCase
  include DepInject

  provide(
    logger: MockLogger,
    add_task: MockAddTaskCommand
  )

  def execute(task_name)
    task = @add_task.execute(task_name)
    @logger.log("Executing #{task}")
  end
end


class InvalidUseCase
  include DepInject

  provide(
    logger: MockLogger
  )
end

class InvalidPublicMethodUseCase
  include DepInject

  provide(
    logger: MockLogger
  )

  def execute(task_name)
    @logger.log("Executing #{task_name}")
  end

  def extra_public_method
    "This should raise an error"
  end
end

RSpec.describe DepInject do
  it "has a version number" do
    expect(DepInject::VERSION).not_to be nil
  end

  describe 'class using dependency injection with valid pattern' do
    let(:usecase) { ValidUseCase.build }

    it 'injects the dependencies properly' do
      expect(usecase.instance_variable_get(:@logger)).to be_a(MockLogger)
      expect(usecase.instance_variable_get(:@task_manager)).to be_a(MockTaskManager)
    end

    it 'has execute as a public method' do
      expect(usecase.public_methods).to include(:execute)
    end

    it 'can successfully call execute' do
      result = usecase.execute("Test Task")
      expect(result).to eq("Logged: Executing Task Test Task created")
    end
  end

  describe 'injects dependency also using DepInject' do
    let(:usecase) { OtherValidUseCase.build }

    it 'injects the dependencies properly' do
      expect(usecase.instance_variable_get(:@logger)).to be_a(MockLogger)
      expect(usecase.instance_variable_get(:@add_task)).to be_a(MockAddTaskCommand)
    end

    it 'has execute as a public method' do
      expect(usecase.public_methods).to include(:execute)
    end

    it 'can successfully call execute' do
      result = usecase.execute("Test Task")
      expect(result).to eq("Logged: Executing Task Test Task created")
    end
  end

  describe 'class without execute method' do
    it 'raises NotImplementedError if execute method is missing' do
      expect { InvalidUseCase.build }.to raise_error(NotImplementedError, "Class InvalidUseCase must define an `execute` method")
    end
  end

  describe 'class with extra public method' do
    it 'raises PublicMethodError if extra public method is defined' do
      expect { InvalidPublicMethodUseCase.build }.to raise_error(DepInject::PublicMethodError, "Class InvalidPublicMethodUseCase should only define `execute` as a public method. Additional public methods: extra_public_method")
    end
  end

end
