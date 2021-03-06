states = classes;
obs = classes;
%Uniform distribution for start probability
start_p = (1/length(classes{1}))*ones(1,length(classes{1}));

%emit_p = centers-projected_centers;
emit_p=cell(1,length(projected_centers));
for i=1:length(projected_centers)
    a=[];
    for j=1:length(projected_centers{i})
        for jj=1:length(centers{i+1})
            a(j,jj)=norm(abs(centers{i+1}(jj,:)-projected_centers{i}(j,:)));
        end
    end
    emit_p{i}=a;
end
%Transition probability
trans_p=scores;

   T = {};
   %
   for state = 1:length(states{1})
       %%          prob.           V. path  V. prob.
       T{state} = {start_p(state),states{1}(state),start_p(state)};
   end
   %Obs is 30, we have 30 observations
   for output = 1:length(obs)-1
       U = {};
       %for the following for loop, each state has different length for my
       %case
       for next_state = 1:length(states{output+1})
           total = 0;
           argmax = [];
           valmax = 0;
           for source_state = 1:length(states{output})
               Ti = T{source_state};
               prob = Ti{1};
               v_path = Ti{2};
               v_prob = Ti{3};
               % Emission is for the optical flow
               % If we have scorefor the next state it will be
               % score(next_state) otherwise it will be score(source_state)  ??
               p = (1/(1+exp(-emit_p{output}(source_state,next_state)))) * (1/(1+exp(-trans_p{output+1}(next_state))));
               p=(p);
               prob = prob*p;
               v_prob = (v_prob*p);
               total = total + prob;
               if v_prob > valmax
                   argmax = [v_path, states{output+1}(next_state)];
                   valmax = v_prob;
               end
           end
           U{next_state} = {total,argmax,valmax};
       end
       % Dont be confused about T, it goes up and computes it again
       T = U;
   end
   %% apply sum/max to the final states:
   total = 0;
   argmax = [];
   valmax = 0;
   %edit this part, we just want the last obseravtion fram
   for state = 1:length(states{length(obs)})
       Ti = T{state};
       prob = Ti{1}; v_path = Ti{2}; v_prob = Ti{3};
       total = total + (prob);
       if v_prob > valmax
           argmax = v_path;
           valmax = v_prob;
       end
   end