module Lms
  class ScenarioMachine
    attr_accessor :loan

    def initialize(loan)
      @loan = loan
    end

    def execute
      scenarios = {}

      loan.scenario_configs.each do |config|
        case config.name
        when "actual_plus_worst"
          scenarios[:actual_plus_worst] = build_scenario(config)
        when "actual_plus_best"
          scenarios[:actual_plus_best] = build_scenario(config)
        end
      end

      scenarios
    end

    private

    def build_scenario(config)
      # bbal = beginning balance
      # bprn = beginning principal
      # dint = daily interest accrued
      # cint = cumulative interest
      # tpay = total payment made
      # pded = principal deducted
      # ided = interest deducted
      # ebal = ending balance
      # eprn = ending principal
      # eint = ending interest

      scheduled_repayments = []

      if config.name == "actual_plus_best"
        scheduled_repayments = config.data["scheduled_repayments"]
        # Remove scheduled repayments if they
        # are supposed to be overriden by actual events
        scheduled_repayments.delete_if do |e|
          DateTime.parse(e["date"]) <= DateTime.parse(loan.actual_events.pluck(:date).sort.last)
        end
      end


      cache = {}

      (loan.start_date.to_date..(loan.start_date.to_date + loan.term_count.days)).map{ |date| date.strftime("%Y-%m-%d") }.map.with_index do |day, i|
        events = loan.actual_events.where(date: day)
        if i == 0
          bbal = loan.amount.to_f
          bprn = loan.amount.to_f
          dint = bbal*loan.interest_per_day.to_f
          cint = dint

          cache = {
            date: loan.start_date.strftime("%Y-%m-%d"),
            bbal: bbal,
            bprn: bprn,
            dint: dint,
            cint: cint,
            tadd: 0.to_f,
            tpay: 0.to_f,
            pded: 0.to_f,
            ided: 0.to_f,
            ebal: bbal + dint,
            eprn: bprn,
            eint: cint,
            schd: nil,
          }
        else
          next if cache[:ebal] <= 0
          unless events.blank?
            events.each do |event|
              bbal = cache[:ebal]
              bprn = cache[:eprn]
              dint = bbal*loan.interest_per_day.to_f
              cint = cache[:cint] + dint

              case event.name
              when "add_money"
                tadd = event.data[:amount]

                eprn = bprn + tadd
                eint = cint
                ebal = bbal + dint + tadd
              when "sub_money"
                tpay = event.data["amount"]

                if tpay >= cint
                  ided = cint
                  pded = tpay - cint
                else
                  ided = tpay
                  pded = 0.to_f
                end

                ebal = (bbal + dint) - tpay
                eprn = bprn - pded
                eint = cint - ided
              end

              cache = {
                date: day,
                bbal: bbal,
                bprn: bprn,
                dint: dint,
                cint: cint,
                tadd: tadd.to_f,
                tpay: tpay.to_f,
                pded: pded.to_f,
                ided: ided.to_f,
                ebal: ebal,
                eprn: eprn,
                eint: eint,
                schid: nil,
              }
            end
          else
            bbal = cache[:ebal]
            bprn = cache[:eprn]
            dint = bbal*loan.interest_per_day.to_f
            cint = cache[:cint] + dint
            eint = cint
            ebal = bbal + dint
            eprn = bprn
            eint = cint

            cache = {
              date: day,
              bbal: bbal,
              bprn: bprn,
              dint: dint,
              cint: cint,
              tpay: 0.to_f,
              pded: 0.to_f,
              ided: 0.to_f,
              ebal: ebal,
              eprn: eprn,
              eint: eint,
              schd: nil,
            }
          end
        end

        scheduled_repayments.map do |r|
          if r["date"] == day
            cache[:tpay] = r["amount"]

            if amount >= cache[:cint]
              cache[:ided] = cache[:cint]
              cache[:pded] = cache[:tpay] - cache[:cint]
            else
              cache[:ided] = cache[:tpay]
              cache[:pded] = 0.to_f
            end

            cache[:ebal] = cache[:ebal] - r["amount"]
            cache[:eprn] = cache[:eprn] - cache[:pded]
            cache[:eint] = cache[:eint] - cache[:ided]
            cache[:schd] = true
          end
        end

        cache
      end.compact
    end
  end
end
