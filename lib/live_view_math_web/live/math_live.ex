defmodule LiveViewMathWeb.MathLive do
  use LiveViewMathWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket), do: send(self(), :generate_numbers)

    {:ok,
     assign(socket,
       question_num1: 0,
       question_num2: 0,
       right_answers: 0,
       wrong_answers: 0,
       math_form: to_form(%{"answer" => 0})
     )}
  end

  def handle_info(:generate_numbers, socket) do
    {num1, num2} = generate_numbers()
    socket = assign(socket, question_num1: num1, question_num2: num2)
    {:noreply, socket}
  end

  defp generate_numbers() do
    num1 = :rand.uniform(10)
    num2 = :rand.uniform(10)
    IO.inspect(num1)
    IO.inspect(num2)
    {num1, num2}
  end

  defp check_question(num1, num2, ans) do
    num1 + num2 == ans
  end

  def handle_event("answer_form", %{"answer" => answer_str}, socket) do
    socket =
      case(Integer.parse(answer_str)) do
        :error ->
          socket
          |> assign_invalid_answer()

        {answer, _} ->
          update_socket_based_on_answer(socket, answer)
      end

    {:noreply, socket}
  end

  defp assign_invalid_answer(socket) do
    assign(socket,
      math_form: to_form(%{"answer" => 0}, errors: [answer: {"Answer must be a number", []}])
    )
  end

  defp update_socket_based_on_answer(socket, answer) do
    correct = check_question(socket.assigns.question_num1, socket.assigns.question_num2, answer)

    {num1, num2} = generate_numbers()

    socket
    |> assign(
      math_form: to_form(%{"answer" => 0}),
      right_answers:
        if(correct, do: socket.assigns.right_answers + 1, else: socket.assigns.right_answers),
      wrong_answers:
        if(correct, do: socket.assigns.wrong_answers, else: socket.assigns.wrong_answers + 1),
      question_num1: num1,
      question_num2: num2
    )
  end
end
