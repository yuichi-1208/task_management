require 'rails_helper'
RSpec.describe 'タスク管理機能', type: :system do
  def user_login
    visit new_session_path
    fill_in 'session[email]', with: 'sample@dic.com'
    fill_in 'session[password]', with: 'samplesample'
    click_button 'ログイン'
  end

  def admin_user_login
    visit new_session_path
    fill_in 'session[email]', with: 'admin2@dic.com'
    fill_in 'session[password]', with: 'admin2admin2'
    click_button 'ログイン'
  end

  before do
    @user = FactoryBot.create(:user)
    @admin_user = FactoryBot.create(:admin_user)

    @task1 = FactoryBot.create(:task, name: 'task1', user: @user)
    @task2 = FactoryBot.create(:second_task, name: 'task2', user: @user)
    @task3 = FactoryBot.create(:third_task, name: 'task3', user: @user)

    @label1 = FactoryBot.create(:label)
    @label2 = FactoryBot.create(:second_label)

    @labeling1 = FactoryBot.create(:labeling)
    @labeling2 = FactoryBot.create(:second_labeling)

    user_login
  end

  def show_btns(index)
    visit tasks_path
    sleep 1
    show_btns = all('.show')
    show_btns[index]
  end

  describe '検索機能' do
    context 'ラベル検索をした場合' do
      it "ラベルに完全一致するタスクが絞り込まれる" do
        visit tasks_path
        select 'A', from: 'label'
        click_on '検索'
        expect(page).to have_content 'task1'
        expect(page).to have_content 'test_content'
      end
    end
    context 'タイトルであいまい検索をした場合' do
      it "検索キーワードを含むタスクで絞り込まれる" do

        visit tasks_path
        # タスクの検索欄に検索ワードを入力する (例: task)
        fill_in "タスク名",	with: "k1"
        # 検索ボタンを押す
        click_on '検索'
        expect(page).to have_content 'task1'
        expect(page).not_to have_content 'task2'
      end
    end
    context 'ステータス検索をした場合' do
      it "ステータスに完全一致するタスクが絞り込まれる" do

        # ここに実装する
        visit tasks_path
        # プルダウンを選択する「select」について調べてみること
        select '完了', from: 'ステータス'
        click_on '検索'
        sleep 1
        expect(page).to have_content '完了'
      end
    end
    context 'タイトルのあいまい検索とステータス検索をした場合' do
      it "検索キーワードをタイトルに含み、かつステータスに完全一致するタスク絞り込まれる" do

        # ここに実装する
        visit tasks_path
        fill_in "タスク名",	with: "sk"
        select '完了', from: 'ステータス'
        click_on '検索'
        expect(page).to have_content 'task'
        expect(page).to have_content '完了'
      end
    end
  end

  describe '新規作成機能' do
    context 'タスクを新規作成した場合' do
      it '作成したタスクが表示される' do

      # 1. new_task_pathに遷移する（新規作成ページに遷移する）
      # ここにnew_task_pathにvisitする処理を書く
        visit new_task_path
      # 2. 新規登録内容を入力する
      #「タスク名」というラベル名の入力欄と、「タスク詳細」というラベル名の入力欄にタスクのタイトルと内容をそれぞれ入力する
      # ここに「タスク名」というラベル名の入力欄に内容をfill_in（入力）する処理を書く
      # ここに「タスク詳細」というラベル名の入力欄に内容をfill_in（入力）する処理を書く
        fill_in "タスク名",	with: "task1"
        fill_in "タスク詳細",	with: "sometext"
        select "2020",	from: "task_deadline_1i"
        select "12",	from: "task_deadline_2i"
        select "8",	from: "task_deadline_3i"
        select '着手中', from: 'ステータス'
        select '中', from: '優先順位'
      # 3. 「登録する」というvalue（表記文字）のあるボタンをクリックする
      # ここに「登録する」というvalue（表記文字）のあるボタンをclick_onする（クリックする）する処理を書く
        click_on '登録する'
      # 4. clickで登録されたはずの情報が、タスク詳細ページに表示されているかを確認する
      # （タスクが登録されたらタスク詳細画面に遷移されるという前提）
      # ここにタスク詳細ページに、テストコードで作成したデータがタスク詳細画面にhave_contentされているか（含まれているか）を確認（期待）するコードを書く
        # task = FactoryBot.create(:task, name: 'task1', detail: 'sometext')
        # visit task_path(task)
        expect(page).to have_content 'task1'
        expect(page).to have_content 'sometext'
        expect(page).to have_content '2020'
        expect(page).to have_content '12'
        expect(page).to have_content '8'
        expect(page).to have_content '着手中'
        expect(page).to have_content '中'
      end
    end
    context '終了期限でソートするボタンを押した場合' do
      it '終了期限の降順で表示される' do

        visit tasks_path
        click_on '終了期限'
        sleep 0.5
        task_list = all('.date_row')
        expect(task_list[0]).to have_content '2020年 10月 16日'
        expect(task_list[1]).to have_content '2020年 10月 15日'
        expect(task_list[2]).to have_content '2020年 10月 10日'
        # binding.irb
      end
    end
    context '優先順位でソートするボタンを押した場合' do
      it '優先順位の昇順で表示される' do

        visit tasks_path
        click_on '優先順位'
        sleep 0.5
        task_list = all('.date_priority')
        expect(task_list[0]).to have_content '高'
        expect(task_list[1]).to have_content '中'
        expect(task_list[2]).to have_content '低'
        # binding.irb
      end
    end
  end

  before do
    # 「一覧画面に遷移した場合」や「タスクが作成日時の降順に並んでいる場合」など、contextが実行されるタイミングで、before内のコードが実行される
    visit tasks_path
  end
  describe '一覧表示機能' do
    context '一覧画面に遷移した場合' do
      it '作成済みのタスク一覧が表示される' do

        # テストで使用するためのタスクを作成
        # task = FactoryBot.create(:task, title: 'task')
        # visitした（遷移した）page（タスク一覧ページ）に「task」という文字列が
        # have_contentされているか（含まれているか）ということをexpectする（確認・期待する）
        expect(page).to have_content 'task'
        # expectの結果が true ならテスト成功、false なら失敗として結果が出力される
      end
    end
    # テスト内容を追加で記載する
    context 'タスクが作成日時の降順に並んでいる場合' do
      it '新しいタスクが一番上に表示される' do

        # ここに実装する
        # visit tasks_path
        # binding.irb
        # sleep 1
        # show_btns = all('.show')
        # # binding.irb
        # show_btns[0].click
        show_btns(0).click
        expect(page).to  have_content 'task3'
        # click_link '戻る' #ページ遷移したため再び値の取得が必要
        # sleep 1
        # show_btns = all('.show')
        show_btns(1).click
        # show_btns[1].click
        expect(page).to  have_content 'task2'
      end
    end
  end

  describe '詳細表示機能' do
    context '任意のタスク詳細画面に遷移した場合' do
      it '該当タスクの内容が表示される' do

        # タスク一覧ページに遷移
        visit tasks_path
        # binding.pry
        show_btns = all('.show')
        show_btns[1].click
        # @task = Task.find(params[:id])
        expect(page).to have_content 'Factoryで作ったデフォルトのコンテント２'
      end
    end
    context 'ラベルの付いたタスク詳細画面に遷移した場合' do
      it 'タスクに付けられているラベルが表示される' do

        # タスク一覧ページに遷移
        visit tasks_path
        # binding.pry
        show_btns = all('.show')
        show_btns[1].click
        # @task = Task.find(params[:id])
        expect(page).to have_content 'Factoryで作ったデフォルトのコンテント２'
        expect(page).to have_content 'B'
        expect(page).not_to have_content 'A'
      end
    end
  end
end