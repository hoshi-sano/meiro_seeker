module MyDungeonGame
  module GoToNextFloorEvent
    module_function

    def create(scene)
      scene.instance_eval do
        letter = {
          question: MessageManager.get(:go_to_next?),
        }
        events = {
          yes: lambda {|e| go_to_next_floor; e.finalize },
          no:  lambda {|e| e.finalize },
        }
        YesNoEvent.create(scene, letter, events)
      end
    end
  end
end
