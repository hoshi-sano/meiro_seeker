module MeiroSeeker
  # 各種パラメータ回復演出
  # gainを指定すると、そのパラメータが満タンだった場合に
  # gainに指定した値の分だけ最大値が増える
  module ParamRecoverEvent
    module_function

    def create(scene, target, param, point, gain=nil)
      max_param = "max_#{param}"
      set_param = "#{param}="
      set_max_param = "max_#{param}="

      scene.instance_eval do
        Event.new(if_alive: target) do |e|
          diff = target.send(max_param) - target.send(param)

          if diff.zero? && gain
            target.send(set_max_param, target.send(max_param) + gain)
            target.send(set_param, target.send(max_param))
            msg = MessageManager.send("#{param}_gain", gain)
          else
            target.send(set_param, target.send(param) + point)
            if target.send(param) > target.send(max_param)
              target.send(set_param, target.send(max_param))
            end
            msg = MessageManager.send("#{param}_recover", diff)
          end
          e.set_next_cut_in(ShowMessageEvent.create(self, msg))

          e.finalize
        end
      end
    end
  end
end
