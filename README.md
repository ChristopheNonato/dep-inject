# Dinject

Dinject is a simple Ruby gem that allows for clean and flexible dependency injection in Ruby classes. It provides a constructor method (`build`) and enforces a single public method (`execute`) to encourage well-structured use cases and services. The gem raises errors if other public methods are defined, ensuring that classes stay focused on a single responsibility.

## Features

- **Dependency Injection**: Easily inject dependencies such as repositories, service objects, etc.
- **Enforced Interface**: Ensures that only the `execute` method is public.
- **Error Handling**: Raises specific errors when expected conventions are not followed.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dinject'
```

Then bundle install

## Usage

To use Dinject, include the module in your class, specify your dependencies, and define the execute method. Dinject will handle the injection of the specified dependencies and enforce that only execute is exposed as a public method.

Dependencies can be any class or object. Dinject will initialize and inject them into your use case at runtime. The dependencies are injected as instance variables with the same name as the keys passed in provide.

### Basic Example

```ruby
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

class TaskUseCase
  include Dinject

  provide(
    logger: MockLogger,
    task_manager: MockTaskManager
  )

  def execute(task_name)
    task = @task_manager.create_task(task_name)
    @logger.log("Executing #{task}")
  end
end

# Instantiate using constructor method and execute
usecase = TaskUseCase.build
usecase.execute("Test Task")
```

## Contributing

This project is intended to be a welcoming space for contribution. Pull requests are welcome.

## License

The gem is available as open source under the terms of the MIT License.

