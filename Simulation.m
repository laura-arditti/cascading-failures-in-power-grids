grid = loadcase('case118');
result= rundcpf(grid);
thresholds = abs(result.branch(:,14))*10/8;

num_branch = length(result.branch(:,1));
Cascade = cell(num_branch,1);
for trigger=1:num_branch
    % simulazione di una cascata innescata dal fallimento del branch
    % trigger
    grid = loadcase('case118');
    grid.branch(trigger,11)=0;
    status = grid.branch(:,11);
    result = rundcpf(grid);
    connected = result.success;
    iteration = 0;
    failures = cell(0);
    while connected==1
        num_failures=0;
        iteration = iteration+1;
        failed=[];
        for j=1:num_branch
            if abs(result.branch(j,14))>thresholds(j)
                num_failures=num_failures+1;
                failed(num_failures)=j;
            end
        end
        if num_failures==0
            break
        end
        status(failed)=0;
        grid.branch(:,11)=status;
        failures{end+1}=failed;
        result = rundcpf(grid);
        connected = result.success;
    end
    Cascade{trigger}= failures;
end
s= jsonencode(Cascade);
fid = fopen('Cascade.json','wt');
fprintf(fid, s);
fclose(fid);

s= jsonencode(grid.branch(:,1:2));
fid = fopen('Topology.json','wt');
fprintf(fid, s);
fclose(fid);