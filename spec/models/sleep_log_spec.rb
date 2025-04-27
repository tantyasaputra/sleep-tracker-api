require 'rails_helper'

RSpec.describe SleepLog, type: :model do
  let(:user) { create(:user) }

  describe 'Callbacks' do
    context 'when sleep_at and wake_at are present' do
      it 'automatically calculates the duration' do
        sleep_log = create(:sleep_log, user: user, sleep_at: Time.current - 1.hour, wake_at: Time.current)

        expect(sleep_log.duration).to eq(1.hour)
      end
    end
  end

  describe 'Associations' do
    it { should belong_to(:user) }
  end

  describe '.clock_in' do
    context 'when the user is not already clocked in' do
      it 'creates a new sleep log with current time as sleep_at' do
        expect {
          SleepLog.clock_in(user)
        }.to change { SleepLog.count }.by(1)

        sleep_log = user.sleep_logs.last
        expect(sleep_log.sleep_at).to be_present
        expect(sleep_log.wake_at).to be_nil
      end
    end

    context 'when the user is already clocked in' do
      before { SleepLog.clock_in(user) }

      it 'raises an error' do
        expect {
          SleepLog.clock_in(user)
        }.to raise_error(HandledErrors::InvalidParamsError, 'you are already clocked in!')
      end
    end
  end

  describe '.clock_out' do
    context 'when the user has clocked in' do
      before { SleepLog.clock_in(user) }

      it 'updates the wake_at time and sets duration' do
        sleep_log = user.sleep_logs.last

        expect {
          SleepLog.clock_out(user)
        }.to change { sleep_log.reload.wake_at }.from(nil).to(be_present)

        expect(sleep_log.reload.duration).not_to be_nil
      end
    end

    context 'when the user has not clocked in' do
      it 'raises an error' do
        expect {
          SleepLog.clock_out(user)
        }.to raise_error(HandledErrors::InvalidParamsError, 'you have not clocked in!')
      end
    end
  end
end
