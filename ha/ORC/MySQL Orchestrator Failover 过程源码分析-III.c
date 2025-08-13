�������� | Orchestrator Failover ����Դ�����-III
ԭ�� ����ʩ ��������Դ���� 2022-11-24 16:30 �������Ϻ�
���ߣ�����ʩ
ĳ��˾ר�� DBA ����� MySQL...
������Դ��ԭ��Ͷ��

*��������Դ������Ʒ��ԭ������δ����Ȩ��������ʹ�ã�ת������ϵС�ಢע����Դ��
GetCandidateReplica
// RegroupReplicasGTID will choose a candidate replica of a given instance, and take its siblings using GTID
func RegroupReplicasGTID(
    masterKey *InstanceKey, // ʵ�δ��������� �ҵ��ľ�����
    returnReplicaEvenOnFailureToRegroup bool, // ʵ�δ��������� true
    startReplicationOnCandidate bool, // ʵ�δ��������� false
    onCandidateReplicaChosen func(*Instance), // ʵ�δ��������� nil
    postponedFunctionsContainer *PostponedFunctionsContainer,
    postponeAllMatchOperations func(*Instance, bool) bool, // ʵ�δ��������� promotedReplicaIsIdeal ����
)
RegroupReplicasGTID will choose a candidate replica of a given instance, and take its siblings using GTID

Ӣ�ļ�򵥵�һ�仰, ���Ĳ�֪��զ����.. �������� RegroupReplicasGTID ���Ŀ��ʵ��(��DeadMaster)�Ĵӿ���ѡ��һ�� candidate ����, Ȼ��������Ϊ�����⣬���ӹ����еĴӿ�

Ҫ��� RegroupReplicasGTID ������Ҫ�ȿ������õ�GetCandidateReplica
// GetCandidateReplica chooses the best replica to promote given a (possibly dead) master
func GetCandidateReplica(masterKey *InstanceKey, forRematchPurposes bool) (*Instance, [](*Instance), [](*Instance), [](*Instance), [](*Instance), error) {

    // masterKey ʵ�δ��������� �ҵ��ľ�����. InstanceKey�ṹ����ֻ��Hostname��Port
    // forRematchPurposes ʵ�δ������� true

    // ��������, ����һ��ָ��
    var candidateReplica *Instance
    aheadReplicas := [](*Instance){} // ����������, ���� aheadReplicas != nil
    equalReplicas := [](*Instance){}
    laterReplicas := [](*Instance){}
    cannotReplicateReplicas := [](*Instance){}

    dataCenterHint := ""
    // ����ʵ���Ǹ���Hostname��Port��ȡbackend db database_instance��,  ʵ������һ��instance, ʹ��readInstanceRow����˸�������, ��is_candidate, promotion_rule�ȵ�
    if master, _, _ := ReadInstance(masterKey); master != nil {
        dataCenterHint = master.DataCenter
    }
    // ���ظ�����վ�ĸ����б����ں�ѡѡ��
    // ���ǰ�masterKey�����дӿ��������, ����һ��[](*Instance)
    replicas, err := getReplicasForSorting(masterKey, false)
    if err != nil {
        // �����err, ����ֱ��return. ע���ʱcandidateReplica�ǵ���nil��
        return candidateReplica, aheadReplicas, equalReplicas, laterReplicas, cannotReplicateReplicas, err
    }

    // type StopReplicationMethod string

    // const (
    //  NoStopReplication     StopReplicationMethod = "NoStopReplication"
    //  StopReplicationNormal                       = "StopReplicationNormal"
    //  StopReplicationNice                         = "StopReplicationNice"
    // )
    stopReplicationMethod := NoStopReplication
    // forRematchPurposes ʵ�δ������� true
    if forRematchPurposes {
        stopReplicationMethod = StopReplicationNice // ���� stopReplicationMethod �� StopReplicationNice
    }
    // ���������еĴӿ�, StopReplicationNice, �� �������������
    // ���ظ��� exec coordinates ����Ĵӿ��б�
    replicas = sortedReplicasDataCenterHint(replicas, stopReplicationMethod, dataCenterHint)
    if len(replicas) == 0 {
        return candidateReplica, aheadReplicas, equalReplicas, laterReplicas, cannotReplicateReplicas, fmt.Errorf("No replicas found for %+v", *masterKey)
    }
    candidateReplica, aheadReplicas, equalReplicas, laterReplicas, cannotReplicateReplicas, err = chooseCandidateReplica(replicas)
    if err != nil {
        return candidateReplica, aheadReplicas, equalReplicas, laterReplicas, cannotReplicateReplicas, err
    }
    if candidateReplica != nil {
        mostUpToDateReplica := replicas[0]
        if candidateReplica.ExecBinlogCoordinates.SmallerThan(&mostUpToDateReplica.ExecBinlogCoordinates) {
            log.Warningf("GetCandidateReplica: chosen replica: %+v is behind most-up-to-date replica: %+v", candidateReplica.Key, mostUpToDateReplica.Key)
        }
    }
    log.Debugf("GetCandidateReplica: candidate: %+v, ahead: %d, equal: %d, late: %d, break: %d", candidateReplica.Key, len(aheadReplicas), len(equalReplicas), len(laterReplicas), len(cannotReplicateReplicas))
    return candidateReplica, aheadReplicas, equalReplicas, laterReplicas, cannotReplicateReplicas, nil
}
GetCandidateReplica ���ȸ���masterKey (ֻ���� Hostname �� Port )��ѯ Backend DB��database_instance��������һ��master"����" Ȼ��� Backend DB �в�ѯ�� master �����еĴӿ⣬����һ���������дӿ�*Instance ����Ƭ replicas

ע��

�����"��ȡ"�ӿ�Ĺ����г��� error ���� GetCandidateReplica ����ֱֹ�� return. ����ʱ candidateReplica �ǵ��� nil ��

���ŵ��� sortedReplicasDataCenterHint �� replicas ��������. ��������չ��˵һ���������

sortedReplicasDataCenterHint
// sortedReplicas returns the list of replicas of some master, sorted by exec coordinates
// (most up-to-date replica first).
// This function assumes given `replicas` argument is indeed a list of instances all replicating
// from the same master (the result of `getReplicasForSorting()` is appropriate)
func sortedReplicasDataCenterHint(replicas [](*Instance), stopReplicationMethod StopReplicationMethod, dataCenterHint string) [](*Instance) {
    if len(replicas) <= 1 {  // ���ֻ��һ���ӿ�, ֱ�ӷ���
        return replicas
    }
    // InstanceBulkOperationsWaitTimeoutSeconds Ĭ��10s
    // �� StopReplicationNicely ��ʱ10s, �����ʱ��Ҳֻ�Ǽ�����־. Ȼ��StopReplication
    // Ȼ�� sortInstancesDataCenterHint. ��Ҫ��NewInstancesSorterByExec��Less�������ʵ��. ��˵����ExecBinlogCoordinates��ķ�ǰ��, ���ExecBinlogCoordinatesһ��, Datacenter��DeadMasterһ���ķ�ǰ��
    replicas = StopReplicas(replicas, stopReplicationMethod, time.Duration(config.Config.InstanceBulkOperationsWaitTimeoutSeconds)*time.Second)
    replicas = RemoveNilInstances(replicas)

    sortInstancesDataCenterHint(replicas, dataCenterHint)
    for _, replica := range replicas {
        log.Debugf("- sorted replica: %+v %+v", replica.Key, replica.ExecBinlogCoordinates)
    }

    return replicas
}
��ע�Ϳ��Կ��� sortedReplicas �᷵��һ���� exec coordinates ����Ĵӿ��б�(most up-to-date first) sortedReplicasDataCenterHint �ȵ��� StopReplicas , StopReplicas���˼�����:

���ڱ�����stopReplicationMethod �� StopReplicationNice

���е������дӿ�ִ�� StopReplicationNicely. StopReplicationNicely ����stop slave io_thread, start slave sql_thread, Ȼ������з��ӳٴӿ�WaitForSQLThreadUpToDate, ���ȴ�InstanceBulkOperationsWaitTimeoutSeconds��(Ҳ����Ĭ��10s)

�������InstanceBulkOperationsWaitTimeoutSeconds��, SQL_THREAD����û��Ӧ����������־, Ҳ������.

�ȴ���ʱ���������쳣

StopReplicationNicely ִ����ɺ�, ִ�� StopReplication. ʵ�ʾ���ִ�� stop slave

�Ա�MHA
MHA��ʵ����Dead Master Shutdown Phase ͣ���дӿ� io_thread
MasterFailover.pm
sub do_master_failover {
    ...
    $log->info("* Phase 2: Dead Master Shutdown Phase..\n");
    $log->info();
    force_shutdown($dead_master);
    $log->info("* Phase 2: Dead Master Shutdown Phase completed.\n");
    ...
}


sub force_shutdown($) {
  ...

  my $slave_io_stopper = new Parallel::ForkManager( $#alive_slaves + 1 );
  my $stop_io_failed   = 0;
  $slave_io_stopper->run_on_start(
    sub {
      my ( $pid, $target ) = @_;
    }
  );
  $slave_io_stopper->run_on_finish(
    sub {
      my ( $pid, $exit_code, $target ) = @_;
      return if ( $target->{ignore_fail} );
      $stop_io_failed = 1 if ($exit_code);
    }
  );

  foreach my $target (@alive_slaves) {
    $slave_io_stopper->start($target) and next;
    eval {
      $SIG{INT} = $SIG{HUP} = $SIG{QUIT} = $SIG{TERM} = "DEFAULT";
      my $rc = $target->stop_io_thread();
      $slave_io_stopper->finish($rc);
    };
    if ($@) {
      $log->error($@);
      undef $@;
      $slave_io_stopper->finish(1);
    }
    $slave_io_stopper->finish(0);
  }
���Ǻܺ����, ֻҪ��ʼ Failover ��, ��˵�� MHA ��Ϊ�����Ѿ����ˣ���ôͣ io_thread �ٸ��� Master_Log_File �� Read_Master_Log_Pos ѡ latest slave�� û�����

ServerManager.pm
sub identify_latest_slaves($$) {
  my $self        = shift;
  my $find_oldest = shift;
  $find_oldest = 0 unless ($find_oldest);
  my $log    = $self->{logger};
  my @slaves = $self->get_alive_slaves();
  my @latest = ();
  foreach (@slaves) {
    my $a = $latest[0]{Master_Log_File};
    my $b = $latest[0]{Read_Master_Log_Pos};
    if (
      !$find_oldest
      && (
           ( !$a && !defined($b) )
        || ( $_->{Master_Log_File} gt $latest[0]{Master_Log_File} )
        || ( ( $_->{Master_Log_File} ge $latest[0]{Master_Log_File} )
          && $_->{Read_Master_Log_Pos} > $latest[0]{Read_Master_Log_Pos} )
      )
      )
    {
      @latest = ();
      push( @latest, $_ );
    }
    elsif (
      $find_oldest
      && (
           ( !$a && !defined($b) )
        || ( $_->{Master_Log_File} lt $latest[0]{Master_Log_File} )
        || ( ( $_->{Master_Log_File} le $latest[0]{Master_Log_File} )
          && $_->{Read_Master_Log_Pos} < $latest[0]{Read_Master_Log_Pos} )
      )
      )
    {
      @latest = ();
      push( @latest, $_ );
    }
    elsif ( ( $_->{Master_Log_File} eq $latest[0]{Master_Log_File} )
      && ( $_->{Read_Master_Log_Pos} == $latest[0]{Read_Master_Log_Pos} ) )
    {
      push( @latest, $_ );
    }
  }
  foreach (@latest) {
    $_->{latest} = 1 if ( !$find_oldest );
    $_->{oldest} = 1 if ($find_oldest);
  }
  $log->info(
    sprintf(
      "The %s binary log file/position on all slaves is" . " %s:%d\n",
      $find_oldest ? "oldest" : "latest", $latest[0]{Master_Log_File},
      $latest[0]{Read_Master_Log_Pos}
    )
  );
  if ( $latest[0]{Retrieved_Gtid_Set} ) {
    $log->info(
      sprintf( "Retrieved Gtid Set: %s", $latest[0]{Retrieved_Gtid_Set} ) );
  }
  if ($find_oldest) {
    $self->set_oldest_slaves( \@latest );
  }
  else {
    $self->set_latest_slaves( \@latest );
  }
}

orchestrator �Ǹ��� ExecBinlogCoordinates �Ƚϳ� latest slave

ExecBinlogCoordinates ��Ӧ��binlog�������˼ ��Ӧshow slave status�е�

Relay_Master_Log_File
Exec_Master_Log_Pos ��ʾsql_thread�Ѿ�Ӧ���������ĸ�binlog�ĸ�λ�õ���־.
Ȼ�����벻������, ��Ӧ�ø���ReadBinlogCoordinates�Ƚϳ�latest slave, Ҳ����MHA��ʵ�ַ�ʽ, ��

Master_Log_File
Read_Master_Log_Pos ʹ��ExecBinlogCoordinatesѡLatest Slave�ǿ��ܶ����ݵ�(��ʹ���˰�ͬ��), ����ͨ��tc�������ɸ���orc����ѡlatest slave���µĶ���������.
����ģ�ⷽ����issue: https://github.com/openark/orchestrator/issues/1312 ���޸���NewInstancesSorterByExec��Less�ķ���, ��Ϊʹ��ReadBinlogCoordinatesѡ��latest slave, �ڹ�˾�ķ�֧�������������.
���Ҷ�Orchestrator���˽�, OrchestratorĿ����׷�����������, ��������������. �ܶ๫˾Ҳʹ����Orchestrator, �Ҹо�δ��֪�����������, ����˵, ����, �ʾ���"����׷������ԡ�.

���ڵ�������, ���㿪�˰�ͬ��, Ҳ���ܶ�����.

Ȼ��ì�ܵĵ���, �������ӵĸ����ӳ��Ǵ�Ҷ�Ҫ��غ͹����, ���᳤�ڴ��ڸ��ӳ�״̬, �����Ҿ����Ĺ�˾��������, 99.9%�ļ�Ⱥ�����ӳ���1s��. ����Ⱥ�ڸ߷��ڻ�����һ��, ���ܿ��ֻ��½�; �ֻ�����Щ��Ⱥ�������AP��ҵ��.

��ô��Ȼ���ǿ��Ա�֤�����ӳ�С��1s, ����ReadBinlogCoordinatesѡ��Latest slave���ܵ���"�ָ�ʱ��"���������? ��Ϊ���⼸��Ŀ��ٻָ�, ����Ҫ������ʱ���޸�������?

��ô��׼ȷ�ķ�ʽ��Ҫ������ slave sql_thread ����. orchestrator ��Ȼ������ WaitForSQLThreadUpToDate ����ֻ�ȴ���10s(��ʱ).
������� sortInstancesDataCenterHint ����

// sortInstances shuffles given list of instances according to some logic
func sortInstancesDataCenterHint(instances [](*Instance), dataCenterHint string) {  
   sort.Sort(sort.Reverse(NewInstancesSorterByExec(instances, dataCenterHint)))  
}
�������˸� Reverse ����, ������������, Ҫ�� NewInstancesSorterByExec �� Less ����

����sort.Reverse

type reverse struct {
 // This embedded Interface permits Reverse to use the methods of
 // another Interface implementation.
 Interface
}> 
// Less returns the opposite of the embedded implementation's Less method.
func (r reverse) Less(i, j int) bool {
 return r.Interface.Less(j, i)
}> 
// Reverse returns the reverse order for data.
func Reverse(data Interface) Interface {
 return &reverse{data}
}
sort.Reverse ���ص���һ�� *reverse. reverse �ṹ���һ�������ֶ� Interface reverse ������ Less ����, �����ʾ���ʹ�� Interface.Less ��ֻ���������˲���˳�� ���� Reverse() ��Ȼ���ص��ǳ�ʼ���ݣ����Ǹı������ݵ� Less() ����, ������ʱ��������ͻ�����������Ч��.

NewInstancesSorterByExec �� Less ����

func (this *InstancesSorterByExec) Less(i, j int) bool {  
   // Returning "true" in this function means [i] is "smaller" than [j],  
   // which will lead to [j] be a better candidate for promotion  
   // Sh*t happens. We just might get nil while attempting to discover/recover   if this.instances[i] == nil {  
      return false  
   }  
   if this.instances[j] == nil {  
      return true  
   }  
   if this.instances[i].ExecBinlogCoordinates.Equals(&this.instances[j].ExecBinlogCoordinates) {  
      // Secondary sorting: "smaller" if not logging replica updates  
      if this.instances[j].LogReplicationUpdatesEnabled && !this.instances[i].LogReplicationUpdatesEnabled {  
         return true  
      }  
      // Next sorting: "smaller" if of higher version (this will be reversed eventually)  
      // Idea is that given 5.6 a& 5.7 both of the exact position, we will want to promote      
      // the 5.6 on top of 5.7, as the other way around is invalid      
      if this.instances[j].IsSmallerMajorVersion(this.instances[i]) {  
         return true  
      }  
      // Next sorting: "smaller" if of larger binlog-format (this will be reversed eventually)  
      // Idea is that given ROW & STATEMENT both of the exact position, we will want to promote      
      // the STATEMENT on top of ROW, as the other way around is invalid      
      if this.instances[j].IsSmallerBinlogFormat(this.instances[i]) {  
         return true  
      }  
      // Prefer local datacenter:  
      if this.instances[j].DataCenter == this.dataCenter && this.instances[i].DataCenter != this.dataCenter {  
         return true  
      }  
      // Prefer if not having errant GTID  
      if this.instances[j].GtidErrant == "" && this.instances[i].GtidErrant != "" {  
         return true  
      }  
      // Prefer candidates:  
      if this.instances[j].PromotionRule.BetterThan(this.instances[i].PromotionRule) {  
         return true  
      }  
   }   return this.instances[i].ExecBinlogCoordinates.SmallerThan(&this.instances[j].ExecBinlogCoordinates)  
}
����˵, ���Ǹ��� ExecBinlogCoordinates �Ƚϣ���� ExecBinlogCoordinates ��ͬ�ڱ� DataCenter ��DataCenter �� DeadMaster һ����Ϊ"��"

instance.ExecBinlogCoordinates.LogFile = m.GetString("Relay_Master_Log_File") instance.ExecBinlogCoordinates.LogPos = m.GetInt64("Exec_Master_Log_Pos")

��ô����sortInstancesDataCenterHint����ɶҲ������ˣ��������˸��򣬰� most up-to-date �ӿ������ǰ�棬��������ӿ� ExecBinlogCoordinates һ������ӿ������������ĺ�����һ���ķ�ǰ��

��Ҫ������ ExecBinlogCoordinates. PromotionRule ��"�û�"ֻ�����Ҫ����������(��Ϊ�������һ��if��). ExecBinlogCoordinates ��ͬʱ, �������ȼ���:

LogReplicationUpdatesEnabled
SmallerMajorVersion
SmallerBinlogFormat
same DataCenter with dead master
GtidErrant == ""
PromotionRule
������GetCandidateReplica����� chooseCandidateReplica ������ѡһ�� candidate ��chooseCandidateReplica ���յĲ������Ǹո� sortedReplicasDataCenterHint ���ص������� replicas ��Ƭ

chooseCandidateReplica
// chooseCandidateReplica
func chooseCandidateReplica(replicas [](*Instance)) (candidateReplica *Instance, aheadReplicas, equalReplicas, laterReplicas, cannotReplicateReplicas [](*Instance), err error) {
    if len(replicas) == 0 {
        return candidateReplica, aheadReplicas, equalReplicas, laterReplicas, cannotReplicateReplicas, fmt.Errorf("No replicas found given in chooseCandidateReplica")
    }
    // �����ڸ���ʵ���з��ֵ���Ҫ���������Major�汾
    // ����replicas��������ʵ��, 5.6.30, 5.7.32, 5.7.26. ��priorityMajorVersion����5.7
    priorityMajorVersion, _ := getPriorityMajorVersionForCandidate(replicas) 
    // �����ڸ���ʵ���з��ֵ���Ҫ�������binlog��ʽ
    // ����replicas��������ʵ��, mixed, row, row. ��ôpriorityBinlogFormat��row
    priorityBinlogFormat, _ := getPriorityBinlogFormatForCandidate(replicas)

    for _, replica := range replicas {
        replica := replica
        if isGenerallyValidAsCandidateReplica(replica) && // ��һЩ�򵥵ļ��, ����IsLastCheckValid, LogBinEnabled, LogReplicationUpdatesEnabled(ǰ������Ӧ��Ϊtrue), IsBinlogServer(ӦΪfalse)
            !IsBannedFromBeingCandidateReplica(replica) && // �Ƿ񱻲��� PromotionIgnoreHostnameFilters ƥ��, ϣ����ƥ��
            !IsSmallerMajorVersion(priorityMajorVersion, replica.MajorVersionString()) && // ϣ�� replica �汾 <= priorityMajorVersion. ��ϣ���߰汾���Ͱ汾�ӿ�. �Ǳ�������汾��5.6, Ȼ����һ��replica��5.7, �����Ǹ�most up-to-date�Ĵӿ�, ������һ�Ƚ�, ���Ͳ���������, �ͱ�pass��
            !IsSmallerBinlogFormat(priorityBinlogFormat, replica.Binlog_format) { // ϣ������priorityBinlogFormat row, ��replica��mixed��statement
            // this is the one
            candidateReplica = replica
            break
        }
    }
    // ��������ô��, �����ǵĳ���, ������Major�汾��ͬ��, Binlog_formatҲ����row 
    // ��ֻҪ����ӿ�ûʲô"ë��", Ҳû��PromotionIgnoreHostnameFilters��, �ǻ�����replicas[0]����candidateReplica


    // ������������replica������������, candidateReplica��=nil, �ͻ�������if
    if candidateReplica == nil {
        // Unable to find a candidate that will master others.
        // Instead, pick a (single) replica which is not banned.
        for _, replica := range replicas {
            replica := replica
            if !IsBannedFromBeingCandidateReplica(replica) { // ѡ����һ��not banned��
                // this is the one
                candidateReplica = replica
                break
            }
        }
        // ���ѡ����һ�� not banned
        if candidateReplica != nil {
            // ��candidateReplica�� replicas���Ƴ�
            replicas = RemoveInstance(replicas, &candidateReplica.Key)
        }
        return candidateReplica, replicas, equalReplicas, laterReplicas, cannotReplicateReplicas, fmt.Errorf("chooseCandidateReplica: no candidate replica found")
    }

    // ���ߵ�����, ˵����һ��ѭ�����ҵ�candidateReplica��
    // ��candidateReplica�� replicas���Ƴ�
    replicas = RemoveInstance(replicas, &candidateReplica.Key)

    // ����replicas
    for _, replica := range replicas {
        replica := replica
        // ������ʵ�������� candidateReplica �Ĵӿ�, �Ͱ����ŵ� cannotReplicateReplicas��Ƭ��
        if canReplicate, err := replica.CanReplicateFrom(candidateReplica); !canReplicate {
            // lost due to inability to replicate
            cannotReplicateReplicas = append(cannotReplicateReplicas, replica)
            if err != nil {
                log.Errorf("chooseCandidateReplica(): error checking CanReplicateFrom(). replica: %v; error: %v", replica.Key, err)
            }
        // ������ʵ�� ExecBinlogCoordinates SmallerThan candidateReplica.ExecBinlogCoordinates, �ŵ�laterReplicas
        } else if replica.ExecBinlogCoordinates.SmallerThan(&candidateReplica.ExecBinlogCoordinates) {
            laterReplicas = append(laterReplicas, replica)

        // ������ʵ�� ExecBinlogCoordinates == candidateReplica.ExecBinlogCoordinates, �ŵ� equalReplicas
        } else if replica.ExecBinlogCoordinates.Equals(&candidateReplica.ExecBinlogCoordinates) {
            equalReplicas = append(equalReplicas, replica)

        // �����, ˵�����ʵ�� ExecBinlogCoordinates > candidateReplica.ExecBinlogCoordinates, �ŵ� aheadReplicas
        } else {
            // lost due to being more advanced/ahead of chosen replica.
            aheadReplicas = append(aheadReplicas, replica)
        }
    }
    return candidateReplica, aheadReplicas, equalReplicas, laterReplicas, cannotReplicateReplicas, err
}

chooseCandidateReplicaѡ��һ�� candidateReplica ���� ���Ҷ����� replica ���˹���(laterReplicas ��equalReplicas ��aheadReplicas)
CanReplicateFrom �ľ����߼��뿴 https://github.com/Fanduzi/orchestrator-zh-doc ���ò������-�� �жԸò�������ϸ����

�Ӵ�����Կ��� orchestrator ��������0���ݶ�ʧΪ�����ȼ�ѡ�� candidate

    // �����ڸ���ʵ���з��ֵ���Ҫ���������Major�汾
    // ����replicas��������ʵ��, 5.6.30, 5.7.32, 5.7.26. ��priorityMajorVersion����5.7
    priorityMajorVersion, _ := getPriorityMajorVersionForCandidate(replicas) 
    // �����ڸ���ʵ���з��ֵ���Ҫ�������binlog��ʽ
    // ����replicas��������ʵ��, mixed, row, row. ��ôpriorityBinlogFormat��row
    priorityBinlogFormat, _ := getPriorityBinlogFormatForCandidate(replicas)

    for _, replica := range replicas {
        replica := replica
        if isGenerallyValidAsCandidateReplica(replica) && // ��һЩ�򵥵ļ��, ����IsLastCheckValid, LogBinEnabled, LogReplicationUpdatesEnabled(ǰ������Ӧ��Ϊtrue), IsBinlogServer(ӦΪfalse)
            !IsBannedFromBeingCandidateReplica(replica) && // �Ƿ񱻲��� PromotionIgnoreHostnameFilters ƥ��, ϣ����ƥ��
            !IsSmallerMajorVersion(priorityMajorVersion, replica.MajorVersionString()) && // ϣ�� replica �汾 <= priorityMajorVersion. ��ϣ���߰汾���Ͱ汾�ӿ�. �Ǳ�������汾��5.6, Ȼ����һ��replica��5.7, �����Ǹ�most up-to-date�Ĵӿ�, ������һ�Ƚ�, ���Ͳ���������, �ͱ�pass��
            !IsSmallerBinlogFormat(priorityBinlogFormat, replica.Binlog_format) { // ϣ������priorityBinlogFormat row, ��replica��mixed��statement
            // this is the one
            candidateReplica = replica
            break
        }
    }
���������е� replicas ��sortInstancesDataCenterHint���صģ��� ExecBinlogCoordinates �Ӵ�С�������Ƭ(�� ExecBinlogCoordinates ���� index ��0) �������� candidateReplica �Ƿ��� replicas[0] ��ȡ������ MajorVersion �� BinlogFormat (��Ȼ���� isGenerallyValidAsCandidateReplica �� IsBannedFromBeingCandidateReplica )
�ڹٷ��ĵ�Discussion: recovering a dead master��Ҳ������������Find the best replica to promote .
һ������ķ�����ѡ�����µĸ���, ������ܲ���������ȷ��ѡ��
A naive approach would be to pick the most up-to-date replica, but that may not always be the right choice.

���µĸ�������û�б�Ҫ���������䵱�������������ڵ�(���磬binlog ��ʽ��MySQL �汾���ơ����ƹ�������). һζ���ƹ����µĸ������ܻᶪʧ�������� It may so happen that the most up-to-date replica will not have the necessary configuration to act as master to other replicas (e.g. binlog format, MySQL versioning, replication filters and more). By blindly promoting the most up-to-date replica one may lose replica capacity.
orchestrator �������������������������ĸ���.orchestrator attempts to promote a replica that will retain the most serving capacity.
������������, �ӹ���ͬ��
Promote said replica, taking over its siblings.

Bring siblings up to date
���ܵĻ�, ���ڶ��׶�ѡ������; ������ܵĻ�, �û������Ѿ������Ҫ�������ض�������(�� register-candidate ����)

Possibly, do a 2nd phase promotion; the user may have tagged specific servers to be promoted if possible (see register-candidate command).

��������ǵĳ���, ͬһ����Ⱥ������ Major �汾��ͬʵ����Binlog_format Ҳ���� row ��ֻҪ����ӿ�ûʲô"ë��", Ҳû�� PromotionIgnoreHostnameFilters �У��ǻ����� replicas[0] ���� candidateReplica
��ô������ GetCandidateReplica ʣ�µĴ���

    candidateReplica, aheadReplicas, equalReplicas, laterReplicas, cannotReplicateReplicas, err = chooseCandidateReplica(replicas)
    if err != nil { // ���chooseCandidateReplica�ߵ� if candidateReplica == nil { ,�ͻ�������if
        return candidateReplica, aheadReplicas, equalReplicas, laterReplicas, cannotReplicateReplicas, err
    }
    if candidateReplica != nil {
        mostUpToDateReplica := replicas[0]
        
        // �����п��ܵ�
        // ��������汾��5.6, Ȼ����һ��replica��5.7, �����Ǹ�most up-to-date�Ĵӿ�, ������priorityMajorVersion��. ���Ͳ��ʺ���candidate
        if candidateReplica.ExecBinlogCoordinates.SmallerThan(&mostUpToDateReplica.ExecBinlogCoordinates) {
            log.Warningf("GetCandidateReplica: chosen replica: %+v is behind most-up-to-date replica: %+v", candidateReplica.Key, mostUpToDateReplica.Key)
        }
    }
    log.Debugf("GetCandidateReplica: candidate: %+v, ahead: %d, equal: %d, late: %d, break: %d", candidateReplica.Key, len(aheadReplicas), len(equalReplicas), len(laterReplicas), len(cannotReplicateReplicas))
    return candidateReplica, aheadReplicas, equalReplicas, laterReplicas, cannotReplicateReplicas, nil
}
�����ٿ�RegroupReplicasGTID
// RegroupReplicasGTID will choose a candidate replica of a given instance, and take its siblings using GTID
func RegroupReplicasGTID(
    masterKey *InstanceKey, // ʵ�δ��������� �ҵ��ľ�����
    returnReplicaEvenOnFailureToRegroup bool, // ʵ�δ��������� true
    startReplicationOnCandidate bool, // ʵ�δ��������� false
    onCandidateReplicaChosen func(*Instance), // ʵ�δ��������� nil
    postponedFunctionsContainer *PostponedFunctionsContainer,
    postponeAllMatchOperations func(*Instance, bool) bool, // ʵ�δ��������� promotedReplicaIsIdeal ����
) (
    lostReplicas [](*Instance),
    movedReplicas [](*Instance),
    cannotReplicateReplicas [](*Instance),
    candidateReplica *Instance,
    err error,
) {
    var emptyReplicas [](*Instance)
    var unmovedReplicas [](*Instance)

    // candidateReplica�п���==nil
    candidateReplica, aheadReplicas, equalReplicas, laterReplicas, cannotReplicateReplicas, err := GetCandidateReplica(masterKey, true)


    // ���chooseCandidateReplica�ߵ� if candidateReplica == nil { ,�ͻ�������if
        // Unable to find a candidate that will master others.
        // Instead, pick a (single) replica which is not banned.
    if err != nil {
        // returnReplicaEvenOnFailureToRegroupʵ�δ��������� true
        if !returnReplicaEvenOnFailureToRegroup {
            candidateReplica = nil
        }
        return emptyReplicas, emptyReplicas, emptyReplicas, candidateReplica, err
    }

    // onCandidateReplicaChosenʵ�δ��������� nil
    if onCandidateReplicaChosen != nil {
        onCandidateReplicaChosen(candidateReplica) // �����߲�������
    }

    // equalReplicas �� laterReplicas ��������candidateReplica�Ĵӿ�, ���Էŵ�replicasToMove��
    replicasToMove := append(equalReplicas, laterReplicas...)
    hasBestPromotionRule := true
    if candidateReplica != nil {
        // ����replicasToMove
        for _, replica := range replicasToMove {
            // �Ƚ�PromotionRule. �ж�candidateReplica�ǲ����û�prefer��
            if replica.PromotionRule.BetterThan(candidateReplica.PromotionRule) {
                hasBestPromotionRule = false
            }
        }
    }
    moveGTIDFunc := func() error {
        log.Debugf("RegroupReplicasGTID: working on %d replicas", len(replicasToMove))

        // moves a list of replicas under another instance via GTID, returning those replicas
        // that could not be moved (do not use GTID or had GTID errors)
        movedReplicas, unmovedReplicas, err, _ = moveReplicasViaGTID(replicasToMove, candidateReplica, postponedFunctionsContainer)
        unmovedReplicas = append(unmovedReplicas, aheadReplicas...)
        return log.Errore(err)
    }

    // ��� postponeAllMatchOperations ���� recoverDeadMaster�ж���� promotedReplicaIsIdeal
    // ��һЩ�ж�, �������Ͼ��ǿ� hasBestPromotionRule �� candidateReplica��promotion rule�ǲ���MustNotPromoteRule. ���candidateReplica���������, ��moveGTIDFunc�ͷŵ��첽�Ƴ�ִ��
    if postponedFunctionsContainer != nil && postponeAllMatchOperations != nil && postponeAllMatchOperations(candidateReplica, hasBestPromotionRule) {
        postponedFunctionsContainer.AddPostponedFunction(moveGTIDFunc, fmt.Sprintf("regroup-replicas-gtid %+v", candidateReplica.Key))
    } else {
    // ����ͬ��ִ��
        err = moveGTIDFunc()
    }
    // ��û̫���������Ǹ�if else, ����canidateReplicaǡ����prefer���Ǹ�ʱ�����һ����־������, ��elseʱ��ɶ������?

    if startReplicationOnCandidate { // ʵ�δ��������� false. ��DeadMaster����, ���ﲻ�ܴ�true, ��ΪStartReplication�����MaybeEnableSemiSyncReplica, ��������Ҫ���� old master
    // ����old master�Ѿ��������Կ϶�������, �����������errorֱ��return��, ����������start slave��û����ִ�е�
        StartReplication(&candidateReplica.Key)
    }

    log.Debugf("RegroupReplicasGTID: done")
    AuditOperation("regroup-replicas-gtid", masterKey, fmt.Sprintf("regrouped replicas of %+v via GTID; promoted %+v", *masterKey, candidateReplica.Key))
    return unmovedReplicas, movedReplicas, cannotReplicateReplicas, candidateReplica, err
}
���� RegroupReplicasGTID
ѡ�˸� candidateReplica ����, �������� replica ������

��� candidateReplica ��һ�������յ�����, ֻ������ ExecBinlogCoordinates ��

ͨ�� moveReplicasViaGTID ���������� replica(���� aheadReplicas �� cannotReplicateReplicas )�� change master ���� candidateReplica

����RegroupReplicasGTID���������, ʣ�µĹ������Խ�����recoverDeadMaster��, ����recoverDeadMaster ��Ҫ���˼������е������������

recoverDeadMaster ��Ҫ���˼�����

GetMasterRecoveryType ��ȷ��������ʲô��ʽ�ָ����ǻ��� GTID ? PseudoGTID ? ���� BinlogServer ?
��������, ���ǵİ�����ʹ�� RegroupReplicasGTID. ��������һ�����⣬�����������ǵ������Ⲣ��������"����"��ʵ��������˵֮����ѡ���������������Ϊ������ȫ����־���������������õ� prefer ������ͨ��һ���հ� promotedReplicaIsIdeal ȥ�����жϺͱ��
������� lostReplicas �����ҿ�����DetachLostReplicasAfterMasterFailover, ��ô�Ტ�еĶ����� lostReplicas ִ�� DetachReplicaMasterHost. ��ʵ����ִ�� change master to master_host='// {host}'
�����ǰѡ�ٵ� new master �������� prefer ��ʵ��, �������ˣ��� prefer ��������
DelayMasterPromotionIfSQLThreadNotUpToDate �� bug
���� Orchestrator Failover ����Դ�����-��
û����recoverDeadMaster��checkAndRecoverDeadMaster�п����κδ���ִ���� start slave sql_thread
���� checkAndRecoverDeadMaster ִ�е�����ʱ, ���ǿ϶��ᳬʱ��

        if config.Config.DelayMasterPromotionIfSQLThreadNotUpToDate && !promotedReplica.SQLThreadUpToDate() {
            AuditTopologyRecovery(topologyRecovery, fmt.Sprintf("DelayMasterPromotionIfSQLThreadNotUpToDate: waiting for SQL thread on %+v", promotedReplica.Key))
            if _, err := inst.WaitForSQLThreadUpToDate(&promotedReplica.Key, 0, 0); err != nil {
                return nil, fmt.Errorf("DelayMasterPromotionIfSQLThreadNotUpToDate error: %+v", err)
            }
            AuditTopologyRecovery(topologyRecovery, fmt.Sprintf("DelayMasterPromotionIfSQLThreadNotUpToDate: SQL thread caught up on %+v", promotedReplica.Key))
        }
ʵ�ʲ���ȷʵ������. �� issue https://github.com/openark/orchestrator/issues/1430 �У������ڲ���֧Ҳ�޸������ bug ���ҵ�ͬ��Ҳ�� issue �и������ҵĽ���취��

�ܽ�
ͼƬ
����ɷ�ͼ

���Ĺؼ��֣�#MySQL�߿���# #Orchestrator#

�����Ƽ���

�������� | Orchestrator Failover ����Դ�����-I

�������� | Orchestrator Failover ����Դ�����-II

�������� | �����������£��ع�Ч����������

���Ϸ��� | ��� TaskMax
����SQLE
��������Դ������ SQLE ��һ���������ݿ�ʹ���ߺ͹����ߣ�֧�ֶೡ����ˣ�֧�ֱ�׼���������̣�ԭ��֧�� MySQL ��������ݿ����Ϳ���չ�� SQL ��˹��ߡ�

SQLE ��ȡ
����	��ַ
�汾��	https://github.com/actiontech/sqle
�ĵ�	https://actiontech.github.io/sqle-docs-cn/
������Ϣ	https://github.com/actiontech/sqle/releases
������˲�������ĵ�	https://actiontech.github.io/sqle-docs-cn/3.modules/3.7_auditplugin/auditplugin_development.html
������� SQLE ����Ϣ�ͽ����������ٷ�QQ����Ⱥ��637150065...