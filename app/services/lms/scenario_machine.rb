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
          scenarios[:actual_plus_worst] = build_actual_plus_worst_case_scenario
        when "actual_plus_best"
        end
      end

      scenarios
    end

    private

    def build_actual_plus_worst_case_scenario
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
            }
          end
        end

        cache
      end.compact
    end

    def get_day_count(start_date, end_date)
      (end_date - start_date).to_i + 1
    end
  end
end
