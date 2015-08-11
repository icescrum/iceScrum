<div class="backlogs">
    <g:each in="${backlogs}" var="backlog" status="index">
        <div class="backlog ${index == 0 ? 'selected' : ''}"
             tooltip="${backlog.name}"
             tooltip-append-to-body="true"
             tooltip-placement="top">
            <div class="backlog-name text-center">
                <h3>${backlog.count}</h3>
                <b>${backlog.name}</b>
            </div>
            <g:each in="${backlog.colors}" var="color">
                <div style="background-color:${color}"></div>
            </g:each>
        </div>
    </g:each>
</div>